# MinIO Role Molecule Testing

This directory contains Molecule tests for the MinIO Ansible role.

## Prerequisites

To run these tests, you need:

1. Python 3.6 or higher
2. Docker
3. Molecule with docker driver

Install the required packages:

```bash
pip install molecule molecule-docker ansible-lint yamllint pytest-testinfra
```

## Test Scenarios

### Default Scenario

Tests a basic single-node MinIO setup on API Server:

```bash
cd ansible/roles/minio
molecule test -s default
```

### Multi-Node Scenario

Tests the complete architecture with:

- API Server with MinIO
- Blockchain nodes
- Compute nodes

```bash
cd ansible/roles/minio
molecule test -s multi_node
```

## Test Phases

Each test goes through the following phases:

1. **dependency**: Install dependencies
2. **lint**: Run yaml and ansible linting
3. **cleanup**: Clean up test environment
4. **destroy**: Destroy test containers
5. **syntax**: Verify playbook syntax
6. **create**: Create test containers
7. **prepare**: Prepare test environment
8. **converge**: Apply the role
9. **idempotence**: Verify role idempotence
10. **verify**: Run verification tests
11. **cleanup**: Final cleanup
12. **destroy**: Remove test containers

## Customizing Tests

You can customize the tests by setting environment variables:

```bash
# Test with Ubuntu 20.04
MOLECULE_DISTRO=ubuntu2004 molecule test

# Test with Debian 11
MOLECULE_DISTRO=debian11 molecule test
```

## Test Development

To develop or debug tests:

```bash
# Create the test environment and apply the role
molecule create -s default
molecule converge -s default

# Only run verification
molecule verify -s default

# Access the test container
molecule login -s default

# Destroy when done
molecule destroy -s default
```

## Adding New Tests

When adding new tests:

1. Create a new directory under `molecule/`
2. Add `molecule.yml`, `converge.yml`, and `verify.yml` files
3. Include any required prepare or side-effect playbooks
