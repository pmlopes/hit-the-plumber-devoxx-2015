#!/usr/bin/env bash
mvn package
java -jar target/devoxx-2015-fat.jar \
  --redeploy="src/**/*.js,src/**/*.java,src/**/*.html,src/**/*.jade" \
  --onRedeploy="./run.sh"
