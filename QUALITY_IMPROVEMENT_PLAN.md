# Code Quality, Security & Testing Enhancement Plan

## Overview
This document tracks the implementation of enhanced code quality, security scanning, and testing coverage for Blue Plaques London.

## Phase 1: Code Quality & Static Analysis 🔍

### 1.1 OCLint Integration
- [x] Add OCLint to Gemfile and CI dependencies
- [x] Create `.oclint` configuration file with project-specific rules
- [x] Add OCLint step to CI pipeline with failure thresholds
- [ ] Fix any existing violations found

### 1.2 Enhanced Pre-commit Hooks
- [x] Add OCLint to pre-commit config
- [x] Add file size limits and security checks
- [x] Enhance existing SwiftLint rules

## Phase 2: Security & Dependency Management 🔒

### 2.1 Dependency Vulnerability Scanning
- [x] Add `bundle audit` for Ruby gems scanning
- [ ] Add CocoaPods security scanning via `pod audit`
- [x] Integrate security checks into CI pipeline
- [x] Set up failure thresholds for high/critical vulnerabilities

### 2.2 Dependabot Configuration
- [x] Create `.github/dependabot.yml` for Ruby gems and CocoaPods
- [x] Configure update frequency and PR limits
- [ ] Set up auto-merge for patch-level security updates

## Phase 3: Code Coverage Integration 📊

### 3.1 Fix Current Coverage Collection
- [x] Debug existing xcresult coverage export in CI
- [x] Add coverage threshold enforcement (start with 70%, aim for 80%+)
- [ ] Generate HTML coverage reports
- [x] Upload coverage to GitHub Actions artifacts

### 3.2 Coverage Reporting & Visualization
- [ ] Add coverage badge to README
- [ ] Set up coverage trend tracking
- [ ] Add coverage comments to PRs showing diff impact

## Phase 4: Enhanced Testing Coverage 🧪

### 4.1 Identify Coverage Gaps
- [ ] Analyze current coverage report to identify gaps
- [ ] Prioritize critical paths (map functionality, data parsing, networking)
- [ ] Create test coverage improvement roadmap

### 4.2 Add Missing Unit Tests
- [x] Add tests for BPLMapViewModel edge cases
- [x] Add tests for BPLWikipediaParser error handling
- [x] Add tests for BPLPlacemark+Additions parsing logic
- [x] Add tests for networking error scenarios

### 4.3 Integration & UI Tests
- [ ] Add basic UI tests for map interaction
- [x] Add integration tests for Wikipedia article loading
- [x] Add tests for search functionality
- [x] Mock network responses for consistent testing

## Implementation Timeline

### Week 1: Foundation
- [ ] OCLint setup
- [ ] Fix coverage collection
- [ ] Security scanning

### Week 2: Automation
- [ ] Dependabot setup
- [ ] Enhanced pre-commit hooks
- [ ] Coverage thresholds

### Week 3: Testing Enhancement
- [ ] Analyze coverage gaps
- [ ] Add critical unit tests
- [ ] Basic integration tests

### Week 4: Polish & Documentation
- [ ] Coverage reporting
- [ ] CI optimization
- [ ] Update documentation

## Success Metrics

- **Code Quality**: OCLint violations < 10, zero high-severity issues
- **Security**: Zero high/critical vulnerabilities in dependencies
- **Coverage**: >75% line coverage, >80% for critical modules
- **Automation**: 90%+ of dependency updates automated
- **CI Speed**: Total CI time < 15 minutes

## Files to Create/Modify

### New Files:
- [x] `.github/dependabot.yml`
- [x] `.oclint`
- [x] `scripts/coverage-check.sh`
- [x] Additional test files in `BluePlaquesLondonTests/`

### Modified Files:
- [x] `.github/workflows/ci.yml` (enhanced with new checks)
- [x] `.pre-commit-config.yaml` (add OCLint, security checks)
- [x] `Gemfile` (add security gems)
- [x] `fastlane/Fastfile` (add coverage/quality lanes)
- [ ] `README.md` (add badges, update contributing)

## Progress Tracking

### Completed ✅
- Initial plan creation
- OCLint integration and configuration
- Enhanced pre-commit hooks with security checks
- Dependency vulnerability scanning setup
- Dependabot configuration for automated updates
- Coverage threshold enforcement
- Quality assurance lanes in Fastfile
- Added comprehensive unit tests for edge cases
- Added domain model tests (BPLPlacemark)
- Added view model tests (BPLAboutViewModel)
- Enhanced existing tests with error scenarios
- Added networking error handling tests
- Added integration tests for search functionality

### In Progress 🚧
- HTML coverage report generation
- Basic UI tests for map interaction

### Blocked ❌
- None

## Notes
- Start with Phase 1 (OCLint + Coverage Fix) as foundation
- Focus on critical paths first for testing
- Maintain CI speed while adding quality checks