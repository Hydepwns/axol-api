# Axol API Infrastructure - Product Requirements Document

## 1. Overview

This Product Requirements Document (PRD) outlines the specifications and requirements for the Axol API infrastructure, with a focus on the distributed MinIO deployment for blockchain data storage.

### 1.1 Purpose

The Axol API infrastructure provides a robust, secure, and scalable environment for storing and accessing blockchain data. The primary purpose is to:

- Store blockchain data in a distributed and fault-tolerant manner
- Provide secure access to this data via standard S3-compatible APIs
- Monitor and maintain system health
- Ensure data integrity and availability

### 1.2 Scope

This PRD covers:

- MinIO distributed storage deployment
- Tailscale network configuration
- Monitoring and alerting
- Blockchain data management
- Testing and validation

## 2. System Architecture

### 2.1 High-Level Architecture

```ruby
┌─────────────┐     ┌─────────────┐
│  Mini PC 1  │     │  Mini PC 2  │
│  (Dappnode) │◄────►  (Avadao)   │
└─────┬───────┘     └─────┬───────┘
      │                   │
      │    Tailscale      │
      │    Network        │
      │                   │
┌─────▼───────┐     ┌─────▼───────┐
│ Turing      │     │ API Server  │
│ Pi x 4      │◄────► Minio       │
└─────────────┘     └─────────────┘
```

### 2.2 Components

1. **MinIO Servers**
   - Two mini PCs running MinIO in distributed mode
   - Erasure coding configuration for data protection
   - Direct access via Tailscale network

2. **Blockchain Data Storage**
   - Dedicated buckets for different blockchain data types
   - Structured organization of blocks, transactions, and state data
   - Lifecycle management for data retention

3. **Networking**
   - Tailscale-based secure overlay network
   - MagicDNS for hostname resolution
   - Access controls for service endpoints

4. **Monitoring**
   - Prometheus metrics collection
   - Grafana dashboards
   - Alert configuration for system health

## 3. Functional Requirements

### 3.1 MinIO Storage Requirements

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| MIO-01 | Distributed Storage | MinIO must operate across multiple nodes | High |
| MIO-02 | Erasure Coding | Data must be protected with EC:2:1 configuration | High |
| MIO-03 | S3 API Compatibility | Must provide standard S3-compatible API | High |
| MIO-04 | External Access | Must be accessible via Tailscale network | High |
| MIO-05 | Storage Capacity | Must support at least 2TB of blockchain data | Medium |
| MIO-06 | Performance | Must support 100+ concurrent connections | Medium |
| MIO-07 | TLS Support | Must support encrypted connections | Medium |

### 3.2 Network Requirements

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| NET-01 | Tailscale Connectivity | All nodes must be on the same Tailscale network | High |
| NET-02 | MagicDNS | Must use Tailscale MagicDNS for hostname resolution | Medium |
| NET-03 | ACL Configuration | Must implement proper access controls | High |
| NET-04 | Firewall Rules | Must configure host firewalls for secure access | High |

### 3.3 Blockchain Data Requirements

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| BLK-01 | Data Organization | Must organize data in structured buckets | High |
| BLK-02 | Data Retention | Must support configurable retention policies | Medium |
| BLK-03 | Backup | Must support data backup strategies | Medium |
| BLK-04 | Performance | Must optimize for blockchain data access patterns | Medium |

## 4. Non-Functional Requirements

### 4.1 Security

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| SEC-01 | Secret Management | Must use Ansible Vault for secrets | High |
| SEC-02 | Network Isolation | Must limit access to authorized devices | High |
| SEC-03 | Authentication | Must require authentication for all access | High |
| SEC-04 | Audit Logging | Must maintain access logs | Medium |

### 4.2 Performance

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| PERF-01 | Throughput | Must support 50MB/s throughput | Medium |
| PERF-02 | Latency | API requests must complete in <100ms | Medium |
| PERF-03 | Concurrency | Must handle 100+ concurrent clients | Medium |

### 4.3 Reliability

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| REL-01 | Uptime | 99.9% uptime requirement | High |
| REL-02 | Data Durability | Must maintain 99.999% data durability | High |
| REL-03 | Fault Tolerance | Must continue operating with one node failure | High |

## 5. Deployment and Testing

### 5.1 Deployment Process

The deployment uses Ansible for infrastructure as code:

1. Configure inventory with target hosts
2. Prepare secrets with Ansible Vault
3. Execute playbook for MinIO deployment
4. Validate deployment with verification tasks

### 5.2 Testing Strategy

| Test Type | Description | Tools |
|-----------|-------------|-------|
| Unit Testing | Test individual Ansible roles | Molecule |
| Integration Testing | Test component interactions | Molecule, Testinfra |
| Performance Testing | Test throughput and latency | S3 benchmark tools |
| Security Testing | Verify security configurations | Security scanners |

## 6. Future Enhancements

| ID | Enhancement | Description | Priority |
|----|-------------|-------------|----------|
| ENH-01 | Auto-scaling | Add capability to scale with data growth | Low |
| ENH-02 | Multi-region | Support for geographic distribution | Low |
| ENH-03 | Advanced Monitoring | Enhanced metrics and alerting | Medium |
| ENH-04 | Automated Backup | Scheduled backup automation | Medium |

## 7. Appendix

### 7.1 Glossary

- **MinIO**: High-performance, S3-compatible object storage
- **Tailscale**: Secure network connectivity (WireGuard-based VPN)
- **Erasure Coding**: Data protection technique for distributed storage
- **S3 API**: Amazon Simple Storage Service compatible API

### 7.2 References

- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Testing Framework](https://molecule.readthedocs.io/)
