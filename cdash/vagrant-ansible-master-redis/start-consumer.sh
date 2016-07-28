#!/bin/bash

php -f /var/www/CDash/public/submissionConsumer.php > /vagrant/consumer-output.log 2>&1 &
