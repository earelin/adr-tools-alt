# GitHub Actions Troubleshooting Guide

This guide helps resolve common issues with the CI/CD workflows in this repository.

## Snyk Workflow Issues

### ❌ Problem: "Unrecognized named-value: 'secrets'"

**Error Message:**
```
Unrecognized named-value: 'secrets'. Located at position 1 within expression: secrets.SNYK_TOKEN != '' && (...)
```

**Cause:** The `secrets` context cannot be used in job-level `if` conditions in GitHub Actions.

**✅ Solution:** Use step-level checks instead:

```yaml
# ❌ Wrong - at job level
jobs:
  my-job:
    if: ${{ secrets.SNYK_TOKEN != '' }}

# ✅ Correct - at step level
jobs:
  my-job:
    steps:
      - name: Check token
        id: check
        run: |
          if [ -n "$SNYK_TOKEN" ]; then
            echo "token_available=true" >> $GITHUB_OUTPUT
          else
            echo "token_available=false" >> $GITHUB_OUTPUT
          fi
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      
      - name: Use token
        if: steps.check.outputs.token_available == 'true'
        run: echo "Token is available"
```

### ❌ Problem: Snyk CLI not authenticated

**Error Message:**
```
Authentication failed. Please check your Snyk token
```

**✅ Solutions:**

1. **Add SNYK_TOKEN to repository secrets:**
   - Go to Repository → Settings → Secrets and Variables → Actions
   - Click "New repository secret"
   - Name: `SNYK_TOKEN`
   - Value: Your Snyk API token from [snyk.io](https://app.snyk.io/account)

2. **Verify token format:**
   - Token should start with a UUID format
   - No spaces or special characters
   - Generated from your Snyk account settings

3. **Check token permissions:**
   - Token must have appropriate permissions for your organization
   - For organization scans, also add `SNYK_ORG_ID` secret

### ❌ Problem: SARIF upload failures

**Error Message:**
```
Error: Could not upload SARIF file: Invalid SARIF file
```

**✅ Solutions:**

1. **Ensure Snyk generates SARIF:**
   ```yaml
   - name: Snyk test
     run: snyk test --sarif-file-output=results.sarif
     continue-on-error: true
   
   - name: Upload SARIF
     if: always() && hashFiles('results.sarif') != ''
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: results.sarif
   ```

2. **Check file exists before upload:**
   - Use `hashFiles()` function to verify file exists
   - Use `continue-on-error: true` for Snyk steps

### ❌ Problem: Workflow skips without explanation

**✅ Solutions:**

1. **Check workflow triggers:**
   ```yaml
   on:
     push:
       branches: [ trunk ]
     pull_request:
       branches: [ trunk ]
   ```

2. **Add debugging output:**
   ```yaml
   - name: Debug info
     run: |
       echo "Event: ${{ github.event_name }}"
       echo "Ref: ${{ github.ref }}"
       echo "Token available: ${{ env.SNYK_TOKEN != '' }}"
   ```

## General Workflow Issues

### ❌ Problem: Build cache issues

**Error Message:**
```
Error: Failed to restore cache
```

**✅ Solutions:**

1. **Clear cache manually:**
   - Go to Repository → Actions → Caches
   - Delete old or corrupted caches

2. **Update cache configuration:**
   ```yaml
   - name: Setup Rust cache
     uses: Swatinem/rust-cache@v2
     with:
       cache-on-failure: true
       shared-key: "v1" # Bump this to invalidate cache
   ```

### ❌ Problem: Permission denied errors

**✅ Solutions:**

1. **Check workflow permissions:**
   ```yaml
   permissions:
     contents: read
     security-events: write  # For SARIF upload
     actions: read
   ```

2. **Verify repository settings:**
   - Repository → Settings → Actions → General
   - Ensure "Allow GitHub Actions to create and approve pull requests" is enabled

### ❌ Problem: Test failures in CI but not locally

**✅ Solutions:**

1. **Use single-threaded tests:**
   ```yaml
   - name: Run tests
     run: cargo test -- --test-threads=1
   ```

2. **Add debugging:**
   ```yaml
   - name: Debug test failure
     if: failure()
     run: |
       echo "Test failed, debugging..."
       ls -la
       env
   ```

## Environment-Specific Issues

### Development Environment

1. **Missing tools:**
   ```bash
   # Install required tools
   cargo install cargo-audit
   npm install -g snyk
   # or
   brew install snyk
   ```

2. **Authentication:**
   ```bash
   # Authenticate with Snyk
   snyk auth
   
   # Test authentication
   snyk config get api
   ```

### CI Environment

1. **Secrets not available in forks:**
   - Fork PRs don't have access to secrets
   - Use `if: github.event.pull_request.head.repo.full_name == github.repository`

2. **Rate limiting:**
   - Use `continue-on-error: true` for external services
   - Add retry logic for flaky services

## Debugging Commands

### Local Testing

```bash
# Validate workflows
./scripts/validate-workflows.sh

# Test security scans
./scripts/security-scan.sh

# Check individual components
cargo build
cargo test
cargo clippy
cargo fmt --check
```

### GitHub CLI Testing

```bash
# List workflows
gh workflow list

# View workflow runs
gh run list --workflow=ci.yml

# View specific run
gh run view <run-id>

# Re-run failed workflow
gh run rerun <run-id>
```

### Manual Checks

```bash
# Check workflow syntax
yamllint .github/workflows/

# Validate specific workflow
actionlint .github/workflows/snyk.yml

# Test Snyk locally
snyk test
snyk code test
```

## Getting Help

1. **Check workflow logs:**
   - Repository → Actions → Select failed workflow
   - Expand failed steps for detailed logs

2. **Common resources:**
   - [GitHub Actions Documentation](https://docs.github.com/en/actions)
   - [Snyk Documentation](https://docs.snyk.io)
   - [Rust CI Best Practices](https://doc.rust-lang.org/cargo/guide/continuous-integration.html)

3. **File issues:**
   - For workflow problems: Check this troubleshooting guide first
   - For Snyk-specific issues: [Snyk Support](https://support.snyk.io)
   - For general problems: Create an issue in this repository

## Prevention

1. **Use workflow validation:**
   ```bash
   ./scripts/validate-workflows.sh
   ```

2. **Test changes locally:**
   ```bash
   # Before pushing, run:
   cargo build
   cargo test -- --test-threads=1
   ./scripts/security-scan.sh
   ```

3. **Monitor workflow health:**
   - Set up notifications for workflow failures
   - Regularly review workflow run history
   - Keep dependencies updated