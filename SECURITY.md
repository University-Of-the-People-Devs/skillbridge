# Security Policy

## Our Commitment

Security is an important part of SkillBridge.

Because the platform will eventually handle user accounts, profiles, project information, GitHub integrations, and other potentially sensitive data, security issues should be handled responsibly.

## Supported Versions

SkillBridge is currently in the planning and foundation stage.

Security support will apply to the actively maintained version of the project once development begins.

| Version | Supported |
|---------|-----------|
| Development / main | Yes |
| Older versions | No |

## Reporting a Vulnerability

Please **do not create a public GitHub issue** for a suspected security vulnerability.

Instead, report the issue privately to the SkillBridge maintainers.

Include:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Relevant screenshots or logs where appropriate
- Any suggested mitigation

Please do not include passwords, access tokens, API keys, or other sensitive credentials in the report.

## What Should Be Reported Privately?

Examples include:

- Authentication vulnerabilities
- Authorization or access-control issues
- Exposure of private user information
- Database security vulnerabilities
- API security vulnerabilities
- GitHub OAuth/security issues
- Credential or secret exposure
- Cross-site scripting (XSS)
- SQL injection
- Account takeover vulnerabilities
- Other issues that could compromise users or the platform

## Responsible Disclosure

Please give maintainers reasonable time to investigate and address a security issue before publicly disclosing technical details.

Security research should be performed responsibly and without accessing, modifying, or destroying data belonging to other users.

## Security Practices

Contributors should:

- Never commit passwords, API keys, tokens, or secrets.
- Never expose environment variables containing sensitive credentials.
- Follow secure coding practices.
- Validate and sanitize user input.
- Use appropriate authentication and authorization controls.
- Avoid unnecessary collection of personal information.
- Keep dependencies reasonably up to date.
- Review security implications before introducing new integrations.

## Dependencies

Contributors should consider the security implications of third-party libraries, APIs, services, and dependencies introduced into SkillBridge.

Known vulnerabilities should be reported and addressed appropriately.

## GitHub Integration

GitHub integration will require particular attention to:

- OAuth permissions
- Access tokens
- Repository permissions
- User consent
- API security
- Webhooks
- Rate limits
- Private repository data

These areas should be reviewed carefully before implementation.

## Security Discussions

General security improvements may be discussed publicly through GitHub Issues or Discussions when doing so does not expose a vulnerability.

Specific vulnerabilities should always be reported privately.

## Final Principle

Security is a shared responsibility.

Every contributor has a role in helping keep SkillBridge and its community safe.
