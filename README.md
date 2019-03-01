# Kafka project

Describe how to use kafka and implement a pub/sub pattern with ruby app.

## Create executable file

Display `hello world` with an executable ruby file.

<details>
  <summary>Solution</summary>

```sh
mkdir bin
touch bin/console.rb
chmod +x bin/console.rb
```

In `bin/console.rb`.
```ruby
#!/usr/bin/env ruby

puts 'Hello World'

```
</details>

Launch a ruby console with an executable ruby file.

<details>
  <summary>Solution</summary>

```sh
mkdir bin
touch bin/console.rb
```

In `bin/console.rb`.
```ruby
#!/usr/bin/env ruby

require 'irb'

IRB.start

```
</details>

## Produce an event on kafka

Create a Gemfile to manage your dependencies.
Add ruby-kafka.

<details>
  <summary>Solution</summary>

```sh
touch Gemfile
```

```ruby
source 'https://rubygems.org'

gem 'ruby-kafka'

```
</details>

Create a `docker-compose.yml` file to run a kafka client into docker.

<details>
  <summary>Solution</summary>

```sh
touch docker-compose.yml
```

```yml
version: '3'
services:
  # To manage distributed system
  zookeeper:
    image: zookeeper:3.4.9
    restart: unless-stopped
    hostname: zookeeper
    ports:
      - "2181:2181"
    environment:
        ZOO_MY_ID: 1
        ZOO_PORT: 2181
        ZOO_SERVERS: server.1=zookeeper:2888:3888
    volumes:
      - data:/data
      - data:/datalog

  kafka1:
    image: confluentinc/cp-kafka:5.0.0
    hostname: kafka1
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_LISTENERS: LISTENER_DOCKER_INTERNAL://kafka1:19092,LISTENER_DOCKER_EXTERNAL://${DOCKER_HOST_IP:-127.0.0.1}:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: LISTENER_DOCKER_INTERNAL:PLAINTEXT,LISTENER_DOCKER_EXTERNAL:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: LISTENER_DOCKER_INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
      KAFKA_BROKER_ID: 1
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - data:/var/lib/kafka/data
    depends_on:
      - zookeeper

  # Dependency for kafka rest
  # To manage avro schema
  kafka-schema-registry:
    image: confluentinc/cp-schema-registry:5.0.0
    hostname: kafka-schema-registry
    ports:
      - "8081:8081"
    environment:
      SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: PLAINTEXT://kafka1:19092
      SCHEMA_REGISTRY_HOST_NAME: kafka-schema-registry
      SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081
    depends_on:
      - zookeeper
      - kafka1

  # To manage topics and partitions
  kafka-rest-proxy:
    image: confluentinc/cp-kafka-rest:5.0.0
    hostname: kafka-rest-proxy
    ports:
      - "8082:8082"
    environment:
      KAFKA_REST_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_REST_LISTENERS: http://0.0.0.0:8082/
      KAFKA_REST_SCHEMA_REGISTRY_URL: http://kafka-schema-registry:8081/
      KAFKA_REST_HOST_NAME: kafka-rest-proxy
      KAFKA_REST_BOOTSTRAP_SERVERS: PLAINTEXT://kafka1:19092
    depends_on:
      - zookeeper
      - kafka1
      - kafka-schema-registry

volumes:
  data:
    driver: local
```

</details>

Initialize a kafka client with brokers, client_id and logger.
Deliver message to kafka client with 'coucou' topic.
Consume message from kafka client on 'coucou' topic.
See https://github.com/zendesk/ruby-kafka/

<details>
  <summary>Solution</summary>

```ruby
require 'kafka'

kafka = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))
kafka.deliver_message('Hello word!', topic: 'coucou')
kafka.each_message(topic: 'coucou') { |m| puts m.value }
```

In `bin/console.rb`.
```ruby
#!/usr/bin/env ruby

require 'irb'
require 'kafka'

KAFKA = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))

IRB.start
```

</details>

Deliver asynchronous messages by batches to kafka client.

<details>
  <summary>Solution</summary>

```ruby
require 'kafka'

kafka = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))
producer = kafka.async_producer

at_exit { producer.shutdown }

producer.produce('Hello world!', topic: 'coucou')
```

In `bin/console.rb`.
```ruby
#!/usr/bin/env ruby

require 'irb'
require 'kafka'

KAFKA = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))
KAFKA_PRODUCER = KAFKA_CLIENT.async_producer(delivery_threshold: 500, delivery_interval: 1, max_queue_size: 1000)

at_exit { KAFKA_PRODUCER.shutdown }

IRB.start
```

</details>

## Create a consumer task

Launch a consumer with ruby executable file

<details>
  <summary>Solution</summary>

```sh
touch bin/consumer.rb
chmod +x bin/consumer.rb
``` 

In bin/consumer.rb
```ruby
#!/usr/bin/env ruby

require 'kafka'

kafka = Kafka.new(['localhost:9092'])

consumer = kafka.consumer(group_id: 'KafkaProject-group')

consumer.subscribe('coucou')
consumer.subscribe('cool')

trap('TERM') { consumer.stop }

logger = Logger.new(STDOUT)

consumer.each_message do |message|
  logger.info(message.topic)
  logger.info(message.offset)
  logger.info(message.value)
end
```

</details>
