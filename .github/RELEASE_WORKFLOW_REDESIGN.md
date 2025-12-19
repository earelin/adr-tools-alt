# New Release Workflow - Simplified Build & Deploy

## Overview

Replaced the complex release workflow with a streamlined approach that focuses solely on building and attaching executables when a GitHub release is published.

## Workflow Design

### **Trigger: GitHub Release Published**
```yaml
on:
  release:
    types: [published]
```

**Benefits:**
- ✅ **Manual Control**: Releases are created manually through GitHub UI
- ✅ **Pre-release Support**: Automatically skips pre-releases
- ✅ **Clean Process**: No complex version validation or SBOM generation during release
- ✅ **Focused Purpose**: Single responsibility - build and attach binaries

### **Platform Matrix**

| Platform | Architecture | Target | Binary Name |
|----------|--------------|--------|-------------|
| **Linux** | x86_64 | `x86_64-unknown-linux-gnu` | `adr-tools-alt-linux-x86_64` |
| **Linux** | x86_64 (musl) | `x86_64-unknown-linux-musl` | `adr-tools-alt-linux-x86_64-musl` |
| **Linux** | aarch64 | `aarch64-unknown-linux-gnu` | `adr-tools-alt-linux-aarch64` |
| **Windows** | x86_64 | `x86_64-pc-windows-msvc` | `adr-tools-alt-windows-x86_64.exe` |
| **macOS** | x86_64 | `x86_64-apple-darwin` | `adr-tools-alt-macos-x86_64` |
| **macOS** | Apple Silicon | `aarch64-apple-darwin` | `adr-tools-alt-macos-aarch64` |

### **Cross-Compilation Strategy**

#### **Native Builds**
- Windows (MSVC)
- macOS (both architectures)  
- Linux x86_64

#### **Cross-Compilation (using `cross`)**
- Linux musl (static linking)
- Linux aarch64 (ARM64)

## Workflow Jobs

### **1. Build Release (`build-release`)**

#### **Conditional Execution**
```yaml
if: ${{ !github.event.release.prerelease }}
```
- Only runs for stable releases (not pre-releases)
- Skips alpha, beta, rc releases

#### **Build Process**
1. **Environment Setup**
   - Checkout source code
   - Install Rust toolchain with target support
   - Setup build cache for faster compilation

2. **Cross-Compilation Setup** (when needed)
   - Install `cross` tool for complex targets
   - Install platform-specific dependencies

3. **Binary Build**
   - Use native `cargo build` or `cross build` based on target
   - Build optimized release binaries
   - Target-specific optimizations

4. **Binary Validation**
   - Verify binary exists and is executable
   - Test basic functionality (`--version` check)
   - Validate file permissions

5. **Asset Preparation**
   - Copy binary to staging with final asset name
   - Set correct executable permissions
   - Prepare for upload

6. **Release Attachment**
   - Upload binary to GitHub release
   - Set appropriate content type
   - Backup to GitHub Actions artifacts

### **2. Release Summary (`release-summary`)**

#### **Success Reporting**
- Comprehensive build status summary
- Platform compatibility matrix
- Direct links to release and downloads
- Security notes about build provenance

#### **Failure Handling**
- Clear error reporting if builds fail
- Links to failed job logs
- Exit with error to mark workflow as failed

## Release Process

### **Step 1: Create GitHub Release**
```bash
# Manual process via GitHub UI or CLI
gh release create v1.0.0 \
  --title "Release v1.0.0" \
  --notes "Release notes here"
```

### **Step 2: Automatic Build**
- Workflow triggers automatically
- Builds all platform binaries
- Attaches to the release

### **Step 3: Download & Use**
```bash
# Users can download platform-specific binaries
curl -L https://github.com/owner/repo/releases/download/v1.0.0/adr-tools-alt-linux-x86_64 -o adr-tools-alt
chmod +x adr-tools-alt
./adr-tools-alt --version
```

## Advantages Over Previous Workflow

### **✅ Simplicity**
- **Single Purpose**: Only builds and attaches binaries
- **Clear Trigger**: Manual release creation
- **No Complex Logic**: No version validation, SBOM generation, or pre-release handling

### **✅ Reliability** 
- **Focused Testing**: Only tests binary functionality
- **Reduced Dependencies**: Fewer external tools and APIs
- **Fail-Fast**: Quick feedback if builds fail

### **✅ User Experience**
- **Immediate Availability**: Binaries attached as soon as release is created
- **Clear Naming**: Consistent, descriptive binary names
- **Platform Coverage**: All major platforms and architectures

### **✅ Maintenance**
- **Easier Debugging**: Simpler workflow to troubleshoot
- **Clearer Logs**: Focused job output
- **Reduced Complexity**: Fewer moving parts to maintain

## Security & Quality

### **Build Security**
- ✅ **Source Authenticity**: Builds from tagged source only
- ✅ **Audit Trail**: Full GitHub Actions build logs
- ✅ **Reproducible**: Consistent build environment
- ✅ **Validated**: Basic functionality testing

### **Binary Quality**
- ✅ **Optimized**: Release builds with full optimizations
- ✅ **Static Linking**: musl builds for maximum compatibility
- ✅ **Multi-Architecture**: Native builds for performance
- ✅ **Tested**: Version check validation

## Integration with CI/CD

### **Separation of Concerns**
- **CI Pipeline**: Fast feedback for PRs (code quality, tests)
- **CD Pipeline**: Comprehensive security validation for trunk
- **Release Pipeline**: Binary building and distribution

### **Quality Gates**
1. **PR Validation**: CI pipeline ensures code quality
2. **Security Validation**: CD pipeline on trunk ensures security
3. **Manual Release**: Human decision point for releases
4. **Automated Distribution**: Release pipeline builds and attaches binaries

## Migration Benefits

### **For Developers**
- **Simpler Process**: Create release → binaries appear automatically
- **Faster Releases**: No complex validation during release
- **Clear Status**: Obvious success/failure indication

### **For Users**
- **Immediate Access**: Binaries available as soon as release is published
- **Consistent Experience**: Predictable binary names and locations
- **Platform Support**: Comprehensive architecture coverage

### **For Maintenance**
- **Reduced Complexity**: Single-purpose workflow
- **Easier Updates**: Simple matrix-based configuration
- **Clear Troubleshooting**: Focused job responsibilities

## Future Enhancements

### **Possible Additions**
- **Checksum Generation**: SHA256 checksums for binaries
- **Code Signing**: Binary signing for enhanced security
- **Container Images**: Docker images alongside binaries
- **Package Registries**: Automatic publishing to package managers

### **Monitoring**
- **Build Analytics**: Track build times and success rates
- **Download Metrics**: Monitor binary download patterns
- **User Feedback**: Release usage and platform preferences

The new release workflow provides a clean, reliable, and maintainable approach to binary distribution while maintaining all the quality and security benefits of the previous system.