# SonarQube Quality Gate check

Check the Quality Gate of your code with [SonarQube](https://www.sonarqube.org/) to ensure your code meets your own quality standards before you release or deploy new features.

<img src="./images/SonarQube-72px.png">

SonarQube is the leading product for Continuous Code Quality & Code Security. It supports most popular programming languages, including Java, JavaScript, TypeScript, C#, Python, C, C++, and many more.

## Requirements

Repository with SonarQube analysis results.

## Usage

The workflow, usually declared in `.github/workflows/build.yml`, should looks like:

```yaml
on:
  # Trigger analysis when pushing in master or pull requests, and when creating
  # a pull request. 
  push:
    branches:
      - master
  pull_request:
      types: [opened, synchronize, reopened]
name: Main Workflow
jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        # Disabling shallow clone is recommended for improving relevancy of reporting
        fetch-depth: 0
      #Triggering SonarQube analysis as results of it is required by Quality Gate check
    - name: SonarQube Scan
      uses: sonarsource/sonarqube-scan-action@master
      env:
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    - name: SonarQube Quality Gate check
      uses: sonarsource/sonarqube-quality-gate-action@master
      # Force to fail step after specific time
      timeout-minutes: 5
      env:
       SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

```

You can change location of report metadata file by using the optional input `scanMetadataReportFile` like this:

```yaml
uses: sonarsource/sonarqube-scan-action@master
with:
  scanMetadataReportFile: target/sonar/report-task.txt
```

### Secrets

- `SONAR_TOKEN` – **Required** this is the token used to authenticate access to SonarQube. You can read more about security tokens [here](https://docs.sonarqube.org/latest/user-guide/user-token/). You should set the `SONAR_TOKEN` environment variable in the "Secrets" settings page of your repository.

## Example of pull request analysis

<img src="./images/SonarQube-analysis-in-Checks.png">

## Do not use this GitHub action if you are in the following situations

* You want to analyze a .NET solution. Read the documentation about our [Scanner for .NET](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-msbuild/).
* You want to analyze C/C++ code. Read the documentation on [analyzing C/C++ code](https://docs.sonarqube.org/latest/analysis/languages/cfamily/).

## Have question or feedback?

To provide feedback (requesting a feature or reporting a bug) please post on the [SonarSource Community Forum](https://community.sonarsource.com/) with the tag `sonarqube-team`.

## License

The Dockerfile and associated scripts and documentation in this project are released under the LGPLv3 License.

Container images built with this project include third party materials.
