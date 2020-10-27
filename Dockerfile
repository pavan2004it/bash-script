# fluentd/Dockerfile
FROM fluent/fluentd-enterprise
RUN ["/opt/td-agent-enterprise/embedded/bin/fluent-gem", "install", "fluent-plugin-elasticsearch", "--no-rdoc", "--no-ri", "-v", "1.10.0"]

