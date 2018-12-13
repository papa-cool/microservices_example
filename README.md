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
