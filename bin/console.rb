#!/usr/bin/env ruby

require 'irb'
require 'kafka'

KAFKA_CLIENT = Kafka.new(['localhost:9092'], client_id: 'KafkaProject', logger: Logger.new(STDOUT))

IRB.start
