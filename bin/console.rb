#!/usr/bin/env ruby

require 'irb'
require 'kafka'

KAFKA_CLIENT = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))
KAFKA_PRODUCER = KAFKA_CLIENT.async_producer(delivery_threshold: 500, delivery_interval: 1, max_queue_size: 1000)

at_exit { KAFKA_PRODUCER.shutdown }

IRB.start
