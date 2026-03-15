# Smart QA Automation Framework - AI Coding Agent Instructions

## Project Overview
This is a **Robot Framework test automation suite** using Selenium for UI testing of OrangeHRM. It combines:
- **Page Object Model (POM)** architecture with self-healing locators
- **AI-driven test result analysis** (Python) that classifies failures
- **Allure + Jenkins CI/CD** reporting pipeline
- **French/English bilingual** documentation and code Comments (norm in this project)

## Architecture & Data Flow

### Layer Structure
```
tests/*.robot (test cases)
  ↓ imports ↓
pages/*.robot (POM - UI locators & element keywords)
  ↓ imports ↓
resources/
  ├─ config.robot (global config: BASE_URL, BROWSER, TIMEOUT)
  ├─ common.robot (shared browser keywords)
  └─ healing.robot (self-healing Click With Healing keyword)
```

**Key insight**: Page files contain only **locator variables + low-level keywords**. Tests import pages and common resources but should not contain locators.

### AI Analysis Integration
- `ai/analyze_robot_output.py` runs POST-TEST to parse `reports/output.xml`
- Classifies failures into 4 categories: "Locator issue", "Timeout / performance", "Functional bug (assertion)", "Environment / browser"
- Outputs `ai_summary.json` + `ai_summary.md` for reporting

## Critical Workflows

### Running Tests (Local)
```bash
robot tests/                        # Run all tests, outputs to reports/
robot tests/login_tests.robot       # Run single file
robot -t "TC_LOGIN_01*" tests/      # Run by tag pattern
```

### CI/CD Pipeline (Jenkins)
1. Checkout → Install deps → Run robot tests (with Allure listener)
2. **AI Analyze Results** → `python ai/analyze_robot_output.py`
3. Archive artifacts (reports/, allure-results/)

**Convention**: Always use `{REPORT_DIR}` env var in Jenkins for reports consistency.

## Project-Specific Patterns

### 1. **Self-Healing Locators** (Critical Pattern)
Located in `resources/healing.robot`, the `Click With Healing` keyword enables automatic fallback:
```robot
Click With Healing    ${primary_locator}    @{fallback_locators}
```
**When to use**: For dynamically changing UI elements (use primary locator + 2-3 fallback XPaths)

### 2. **Page Object Model Conventions**
- **File naming**: `pages/{feature}_page.robot`
- **Locator naming**: ALL_CAPS with descriptive prefix: `${Input_USERNAME}`, `${Button_LOGIN}`
- **Locator format**: Use SeleniumLibrary formats (name=, xpath=, css selector=, etc.)
- **Keyword naming**: Imperative verbs, allow spaces: `Login with`, `Verify Dashboard`
- **Example** ([pages/login_page.robot](pages/login_page.robot)): Define both locators + high-level keywords in same file

### 3. **Test File Structure**
- Import order: SeleniumLibrary → resources → pages
- Use `Test Setup` / `Test Teardown` for browser open/close
- Tag tests with feature ID ([tests/login_tests.robot](tests/login_tests.robot)): `[Tags]  TF-2` (Xray integration)
- **Do NOT** put locators directly in test files; reference page keywords

### 4. **Configuration & Test Data**
- `resources/config.robot`: Global vars (BASE_URL, BROWSER, TIMEOUT, credentials)
- `data/login_data.csv`: External test data for parameterized tests
- Modify `${BASE_URL}` to switch environments; `${TIMEOUT}` for performance tuning

## Failure Analysis Classification
When reviewing/fixing test failures, use AI's categorization logic ([ai/analyze_robot_output.py](ai/analyze_robot_output.py)):
- **Locator issue**: Keywords: no such element, xpath, css selector → Add fallback locators
- **Timeout**: Expected condition, page load → Check network/app or increase `${TIMEOUT}`
- **Functional bug**: Assertion mismatch, should be/contain → App behavior changed
- **Environment issue**: Remote exception, browser disconnect → Check driver/browser installation

## File Organization Rules
- `tests/`: Only \*.robot test cases (1 feature per file, e.g., login_tests.robot, employee_tests.robot)
- `pages/`: One page file per page/feature; no shared keywords here
- `resources/`: config.robot (global), common.robot (browser mgmt), healing.robot (resilience)
- `data/`: CSV + images; reference in tests via relative paths
- `ai/`: Standalone Python analysis scripts; no dependencies on page files

## Adding New Tests
1. Create `pages/{feature}_page.robot` with locators & keywords
2. Create `tests/{feature}_tests.robot` importing pages + resources
3. Add Test Setup/Teardown for browser lifecycle
4. Use `Click With Healing` for fragile elements
5. Tag with Xray feature ID: `[Tags]  TF-XXX`
6. Run: `robot tests/{feature}_tests.robot`

## Dependencies & Environment
- **Framework**: robotframework==7.4, robotframework-seleniumlibrary==6.3.0
- **Driver**: selenium==4.21.0 (auto-managed by SeleniumLibrary)
- **Reporting**: allure-robotframework, lxml
- **Python 3.9+** required for ai/analyze_robot_output.py
- **Virtual env**: `auto-venv/` (Windows activated via `Activate.ps1`)

## Common Pitfalls & Solutions
| Pitfall | Solution |
|---------|----------|
| Test passes locally but fails in Jenkins | Check ${BASE_URL}, ${BROWSER} in config.robot for env-specific values |
| "Element not found" on same test after UI change | Add fallback locators using Click With Healing; don't modify primary |
| Timeout errors | Increase ${TIMEOUT} in config or use Wait Until Element Is Visible before click |
| Locators hardcoded in test files | **WRONG**: Move to pages/*.robot; reference via keywords |
| Missing AI summary in reports | Ensure `python ai/analyze_robot_output.py` runs after tests in Jenkins |
