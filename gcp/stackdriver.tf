# TODO: check if the instance can afford it. fluentd and statsd hog mem like there's no tomorrow, easily eating 200Mb

# ===================== Logs
# run https://dl.google.com/cloudagents/install-logging-agent.sh
# run /opt/google-fluentd/embedded/bin/gem install gem install fluent-plugin-systemd -v 0.3.1
# put this to /etc/google-fluentd/config.d/box.conf
data "template_file" "fluentd_config_box" {
  template = <<EOF
<source>
  @type systemd
  tag box
  path /var/log/journal
  filters [{ "_SYSTEMD_UNIT": "box.service" }, ]
  read_from_head true
  <storage>
    @type local
    persistent false
    path box.pos
  </storage>
  <entry>
    field_map {"MESSAGE": "log", "_PID": ["process", "pid"], "_CMDLINE": "process", "_COMM": "cmd"}
    fields_strip_underscores true
    fields_lowercase true
  </entry>
</source>

<match box>
  @type stdout
</match>
EOF
}

# and this to /etc/google-fluentd/config.d/cloudron-setup.conf
data "template_file" "fluentd_config_cloudron_setup" {
  template = <<EOF
<source>
@type tail
format none
path /var/log/cloudron-setup.log
pos_file /var/lib/google-fluentd/pos/cloudron-setup.pos
read_from_head true
tag cloudron-setup
</source>
EOF
}


# ======================== Metrics
# run curl -s -L https://repo.stackdriver.com/stack-install.sh | bash -s -- --write-gcm
# techncally works, but man, 170Mb of RAM for this crap, and I can't even create alerts from Terraform? Skipping.
