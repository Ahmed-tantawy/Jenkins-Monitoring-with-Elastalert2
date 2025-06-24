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
│   ├── config.yaml
├── rules/
│   ├── jenkins_executor_drop_alert_test.yaml
├── modules/
│   ├── jenkins_metrics_drop_alert.py
├── scripts/
│   ├── webhook.ps1

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

## 📊 Monitoring Rules

### Available Rules

| Rule | Description | Trigger |
|------|-------------|---------|
| `jenkins_executor_drop_alert_test.yaml` | Detects the drops of jenkins excutor with a specific threshold| 
### Creating Custom Rules



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

- **Email** - HTML formatted alerts
- **Webhook** - Custom HTTP endpoints for team space on gmail


### Custom Alert Modules

The project includes several custom alert handlers:

- `jenkins_metrics_drop_alert.py` - Metrics-focused alerting



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
