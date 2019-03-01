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
