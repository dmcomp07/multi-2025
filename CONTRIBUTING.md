# Contributing to Hybrid Cloud DevOps Infrastructure

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and professional
- Welcome all contributors
- Report issues responsibly
- Support a harassment-free community

## How to Contribute

### 1. Report Issues
- Check existing issues first
- Provide clear description
- Include environment details
- Add reproducible steps
- Share error logs/screenshots

### 2. Submit Features
- Open an issue first to discuss
- Explain use case and benefits
- Provide design proposal
- Get maintainer feedback

### 3. Submit Pull Requests
1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes with clear commits
4. Add/update documentation
5. Test thoroughly
6. Push to your fork
7. Open Pull Request with description

## Development Setup

### Prerequisites
```bash
terraform >= 1.8
ansible >= 2.14
kubectl >= 1.28
docker >= 24.0
```

### Local Development
```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/devops-hybrid-cloud.git
cd devops-hybrid-cloud

# Create feature branch
git checkout -b feature/my-feature

# Make changes...

# Validate changes
terraform validate
terraform fmt -recursive
ansible-lint
```

## Code Quality Standards

### Terraform
```bash
# Format
terraform fmt -recursive terraform/

# Validate
terraform validate

# Lint
tflint terraform/
```

### Ansible
```bash
# Syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Lint
ansible-lint ansible/

# Dry run
ansible-playbook playbooks/site.yml --check
```

### Kubernetes
```bash
# Validate manifests
kubectl apply -f kubernetes/ --dry-run=client

# Lint YAML
yamllint kubernetes/
```

### Docker
```bash
# Build test
docker build -t test:latest docker/

# Scan for vulnerabilities
docker scan test:latest
trivy image test:latest
```

## Commit Message Guidelines

Follow conventional commits format:

```
type(scope): subject

body

footer
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Test addition/modification
- `chore`: Build, dependencies, etc.

### Examples
```
feat(terraform): add gke cluster autoscaling
fix(ansible): correct docker daemon configuration
docs(readme): update quick start instructions
```

## Pull Request Process

1. **Update documentation** - README, docs, comments
2. **Add tests** - New tests for new features
3. **Validate code** - Run linters and formatters
4. **Add CHANGELOG entry** - Document your change
5. **Describe PR** - Clear title and description
6. **Link issues** - Reference related issues
7. **Request review** - Assign reviewers

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #(issue number)

## Testing
Describe testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes
- [ ] Terraform validated
- [ ] Ansible linted
```

## Testing Requirements

### Unit Tests
```bash
# Terraform
terraform test

# Python/Ansible
pytest tests/
```

### Integration Tests
```bash
# Smoke tests
bash tests/smoke_tests.sh

# Load tests
bash tests/load_tests.sh
```

### Manual Testing
- Deploy to staging environment
- Verify functionality
- Check monitoring/alerts
- Test disaster recovery

## Documentation

### Update Documentation For:
- New features
- API changes
- Configuration changes
- Breaking changes
- Bug fixes (if significant)

### Documentation Locations
- **README.md** - Overview and quick start
- **docs/ARCHITECTURE.md** - Architecture details
- **docs/QUICK_START.md** - Setup instructions
- **docs/TROUBLESHOOTING.md** - Common issues
- **Code comments** - Implementation details

## Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature
- `documentation` - Documentation needed
- `good first issue` - Good for newcomers
- `help wanted` - Need assistance
- `in progress` - Currently being worked on
- `on hold` - Blocked/waiting

## Release Process

1. Update version numbers
2. Update CHANGELOG
3. Update documentation
4. Create release branch
5. Tag release: `git tag v1.0.0`
6. Create GitHub release
7. Publish release notes

## Review Process

- Maintainers review PRs
- Provide constructive feedback
- Request changes if needed
- Approve when ready
- Merge and deploy

## Questions?

- Open a Discussion for questions
- Check existing documentation
- Review closed issues/PRs
- Ask in GitHub Issues

## Recognition

Contributors will be:
- Listed in project README
- Acknowledged in release notes
- Credited in commit history

## Becoming a Maintainer

Active contributors may be invited to become maintainers. Maintainers have:
- Merge rights
- Repository management access
- Release responsibilities
- Community support role

---

Thank you for contributing! 🎉
