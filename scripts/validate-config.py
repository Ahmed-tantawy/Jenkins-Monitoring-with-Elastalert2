#!/usr/bin/env python3
"""
Configuration validation script for Jenkins Elastalert monitoring
"""

import yaml
import sys
import os
from elasticsearch import Elasticsearch

def load_config():
    """Load and validate config.yaml"""
    config_path = "config/config.yaml"
    
    if not os.path.exists(config_path):
        print("❌ config/config.yaml not found")
        print("💡 Copy config/config.yaml.example to config/config.yaml")
        return None
    
    try:
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        print("✅ Config file loaded successfully")
        return config
    except Exception as e:
        print(f"❌ Error loading config: {e}")
        return None

def test_elasticsearch(config):
    """Test Elasticsearch connection"""
    try:
        es_host = config.get('es_host', 'localhost')
        es_port = config.get('es_port', 9200)
        es_user = config.get('es_username')
        es_pass = config.get('es_password')
        
        print(f"🔍 Testing connection to {es_host}:{es_port}")
        
        if es_user and es_pass:
            es = Elasticsearch([f"{es_host}:{es_port}"], 
                             http_auth=(es_user, es_pass))
        else:
            es = Elasticsearch([f"{es_host}:{es_port}"])
        
        health = es.cluster.health()
        print(f"✅ Elasticsearch connected: {health['status']}")
        return True
        
    except Exception as e:
        print(f"❌ Elasticsearch connection failed: {e}")
        return False

def validate_rules():
    """Validate rule files"""
    rules_dir = "rules"
    if not os.path.exists(rules_dir):
        print("❌ Rules directory not found")
        return False
    
    rule_files = [f for f in os.listdir(rules_dir) if f.endswith('.yaml')]
    
    if not rule_files:
        print("⚠️ No rule files found in rules/")
        return False
    
    print(f"📋 Found {len(rule_files)} rule files:")
    for rule_file in rule_files:
        try:
            with open(os.path.join(rules_dir, rule_file), 'r') as f:
                yaml.safe_load(f)
            print(f"  ✅ {rule_file}")
        except Exception as e:
            print(f"  ❌ {rule_file}: {e}")
            return False
    
    return True

def main():
    print("🔧 Validating Jenkins Elastalert configuration...\n")
    
    # Load config
    config = load_config()
    if not config:
        sys.exit(1)
    
    # Test Elasticsearch
    if not test_elasticsearch(config):
        print("💡 Check your Elasticsearch configuration")
        sys.exit(1)
    
    # Validate rules
    if not validate_rules():
        sys.exit(1)
    
    print("\n🎉 All validations passed!")

if __name__ == "__main__":
    main()
