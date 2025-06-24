# Jenkins-Monitoring-with-Elastalert2

A comprehensive monitoring solution for Jenkins using Elastalert2 to detect anomalies, failures, and performance issues in your Jenkins CI/CD pipeline.

## 🎯 Overview

This project provides automated monitoring and alerting for Jenkins environments using Elastalert2. It includes custom alert handlers, rule configurations, and monitoring templates to help you:

- **Detect Jenkins job failures** and performance degradation
- **Monitor build metrics** and pipeline health
- **Get real-time alerts** via multiple channels (Slack, email, webhooks)
- **Track custom metrics** with flexible rule configurations

## 🚀 Features

- ✅ **Custom Alert Handlers** - Specialized Jenkins-focused alerting
- ✅ **Pre-built Rules** - Ready-to-use monitoring rules for common scenarios
- ✅ **Multi-channel Alerts** - Slack, Email, Webhook, and custom integrations
- ✅ **Metric Tracking** - Build times, failure rates, queue metrics
- ✅ **Easy Configuration** - Template-based setup
- ✅ **Docker Support** - Containerized deployment options

## 📋 Prerequisites

- **Elasticsearch** (7.x or 8.x)
- **Jenkins** with logs shipped to Elasticsearch
- **Python** 3.7+
- **Elastalert2** 2.x

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/jenkins-elastalert-monitoring.git
cd jenkins-elastalert-monitoring
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Install Elastalert2
```bash
pip install elastalert2
```

### 4. Configure Elasticsearch Connection
Copy and modify the configuration:
```bash
cp config/config.yaml.example config/config.yaml
# Edit config/config.yaml with your Elasticsearch details
```

## ⚙️ Configuration

### Basic Configuration

Edit `config/config.yaml`:

```yaml
# Elasticsearch connection
es_host: localhost
es_port: 9200
es_username: elastic
es_password: your_password

# Elastalert settings
buffer_time:
  minutes: 15
run_every:
  minutes: 1

# Custom modules
module_dir: /path/to/modules

# Logging
writeback_index: elastalert_status
writeback_alias: elastalert_alerts
```

### Jenkins Log Configuration

Ensure your Jenkins logs are being shipped to Elasticsearch with proper formatting. Example Logstash configuration included in `config/logstash/`.

## 📁 Project Structure

```
jenkins-elastalert-monitoring/
├── README.md
├── requirements.txt
├── config/
│   ├── config.yaml.example
│   ├── logstash/
│   │   └── jenkins-pipeline.conf
│   └── kibana/
│       └── dashboard-export.json
├── rules/
│   ├── jenkins-job-failure.yaml
│   ├── jenkins-build-time-spike.yaml
│   ├── jenkins-queue-buildup.yaml
│   └── jenkins-node-offline.yaml
├── modules/
│   ├── __init__.py
│   ├── jenkins_metrics_drop_alert.py
│   ├── slack_jenkins_alert.py
│   └── webhook_jenkins_alert.py
├── templates/
│   ├── alert-templates/
│   └── rule-templates/
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── .env.example
├── scripts/
│   ├── setup.sh
│   ├── test-rules.sh
│   └── validate-config.py
└── docs/
    ├── SETUP.md
    ├── RULES.md
    ├── TROUBLESHOOTING.md
    └── API.md
```

## 🔧 Usage

### Running Elastalert2

```bash
# Test configuration
elastalert-test-rule rules/jenkins-job-failure.yaml

# Run with specific config
elastalert --config config/config.yaml --verbose

# Run in background
nohup elastalert --config config/config.yaml > elastalert.log 2>&1 &
```

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d

# Or run standalone container
docker build -t jenkins-elastalert .
docker run -d --name jenkins-elastalert \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/rules:/app/rules \
  jenkins-elastalert
```

## 📊 Monitoring Rules

### Available Rules

| Rule | Description | Trigger |
|------|-------------|---------|
| `jenkins-job-failure.yaml` | Detects job failures | Any job fails |
| `jenkins-build-time-spike.yaml` | Monitors build duration | Build time > 2x average |
| `jenkins-queue-buildup.yaml` | Queue monitoring | >10 jobs queued for 5min |
| `jenkins-node-offline.yaml` | Node availability | Node goes offline |

### Creating Custom Rules

1. Copy a template from `templates/rule-templates/`
2. Modify the query and conditions
3. Place in `rules/` directory
4. Test with `elastalert-test-rule`

Example rule structure:
```yaml
name: Custom Jenkins Rule
type: frequency
index: jenkins-*
num_events: 1
timeframe:
  minutes: 5

filter:
- term:
    jenkins.job.result: "FAILURE"

alert:
- "modules.jenkins_metrics_drop_alert.JenkinsMetricsDropAlert"

# Custom alert parameters
jenkins_job_url: "https://jenkins.company.com"
slack_webhook_url: "https://hooks.slack.com/..."
```

## 🔔 Alert Channels

### Supported Integrations

- **Slack** - Rich notifications with build details
- **Email** - HTML formatted alerts
- **Webhook** - Custom HTTP endpoints
- **MS Teams** - Microsoft Teams integration
- **PagerDuty** - Critical failure escalation

### Custom Alert Modules

The project includes several custom alert handlers:

- `jenkins_metrics_drop_alert.py` - Metrics-focused alerting
- `slack_jenkins_alert.py` - Enhanced Slack notifications
- `webhook_jenkins_alert.py` - Flexible webhook integration

## 📈 Dashboards

Import the included Kibana dashboard (`config/kibana/dashboard-export.json`) for visualization:

- Jenkins job success/failure rates
- Build duration trends
- Queue length over time
- Node utilization metrics

## 🧪 Testing

```bash
# Test all rules
./scripts/test-rules.sh

# Validate configuration
python scripts/validate-config.py

# Test specific rule
elastalert-test-rule rules/jenkins-job-failure.yaml --days 1
```

## 🐳 Docker Support

### Quick Start with Docker

```bash
# Clone and configure
git clone https://github.com/yourusername/jenkins-elastalert-monitoring.git
cd jenkins-elastalert-monitoring
cp docker/.env.example docker/.env

# Edit docker/.env with your settings
# Start the stack
docker-compose -f docker/docker-compose.yml up -d
```

## 🛡️ Security

- Store sensitive credentials in environment variables
- Use Elasticsearch security features
- Regularly update dependencies
- Monitor alert channels for security

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Documentation

- [Setup Guide](docs/SETUP.md) - Detailed installation instructions
- [Rule Configuration](docs/RULES.md) - Creating and managing rules
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [API Reference](docs/API.md) - Custom module development

## 🐛 Troubleshooting

### Common Issues

**Module Import Errors**
```bash
# Ensure module directory is correct in config.yaml
module_dir: /full/path/to/modules

# Check file permissions
chmod +r modules/*.py
```

**Elasticsearch Connection**
```bash
# Test connectivity
curl -X GET "localhost:9200/_cluster/health"

# Check authentication
curl -u elastic:password -X GET "localhost:9200/_cluster/health"
```

For more issues, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`jenkins` `elastalert` `elasticsearch` `monitoring` `ci-cd` `devops` `alerting` `automation` `python` `docker`

## ⭐ Support

If this project helps you, please consider giving it a star! ⭐

For questions and support:
- 📧 Create an [Issue](https://github.com/yourusername/jenkins-elastalert-monitoring/issues)
- 💬 Start a [Discussion](https://github.com/yourusername/jenkins-elastalert-monitoring/discussions)

---

**Built with ❤️ for the DevOps community**
