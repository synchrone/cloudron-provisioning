# ===================== Logs
resource "aws_cloudwatch_log_group" "cloudron" {
  name = "CloudronLogs"
  retention_in_days = 31
  tags {Project = "cloudron"}
}
data "template_file" "cloudwatch_logs" {
  template = <<EOF
[Unit]
Description=AWS CloudWatch Logs service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill cloudwatch-logs
ExecStartPre=-/usr/bin/docker rm cloudwatch-logs
ExecStartPre=-/usr/bin/docker pull lincheney/journald-2-cloudwatch
ExecStart=/usr/bin/docker run -v /var/log/journal/:/var/log/journal/:ro -v /var/lib/misc/journald-2-cloudwatch:/data/journald/:rw lincheney/journald-2-cloudwatch:85c670a5c245 -c /data/journald/cursor -g CloudronLogs -s '{$instanceId} - {$region}'
EOF
}


# ===================== Metrics
data "template_file" "cloudwatch_metrics" {
  template = <<EOF
[Unit]
Description=AWS CloudWatch Metrics service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill cloudwatch-stats
ExecStartPre=-/usr/bin/docker rm cloudwatch-stats
ExecStartPre=-/usr/bin/docker pull pebbletech/cloudwatch-stats
ExecStart=/usr/bin/docker run --name cloudwatch-stats --entrypoint sh pebbletech/cloudwatch-stats:1739575aa274 -c "sed -i '1d' /etc/mtab && /usr/bin/mon-put-instance-stats.py --disk-path=/ --disk-space-avail --persist"
EOF
}

resource "aws_sns_topic" "alarms" {
  name = "cloudron-alarms"
}

resource "aws_cloudwatch_metric_alarm" "insufficient_disk" {
  alarm_name                = "cloudron-insufficient-disk"
  comparison_operator       = "LessThanOrEqualToThreshold"
  namespace                 = "System/Linux"
  metric_name               = "DiskSpaceAvailable"
  dimensions                = {
    InstanceId  = "${aws_instance.cloudron.id}"
    Filesystem  = "-"
    MountPath   = "/"
  }
  period                    = "60"
  evaluation_periods        = "1"
  threshold                 = "2" #GB
  alarm_description         = "Alarm when cloudron disk space is less than 2GB"
  treat_missing_data        = "ignore"
  alarm_actions             = ["${aws_sns_topic.alarms.arn}"]
}
