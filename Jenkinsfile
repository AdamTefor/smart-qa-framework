pipeline {
    agent any

    environment {
        REPORT_DIR     = "reports"
        ALLURE_RESULTS = "allure-results"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                bat '''
                python --version
                python -m pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Robot Tests (with Allure)') {
            steps {
                bat '''
                if not exist %REPORT_DIR% mkdir %REPORT_DIR%
                if not exist %ALLURE_RESULTS% mkdir %ALLURE_RESULTS%

                rem Exécute Robot + génère output.xml dans reports/
                rem + génère les résultats Allure dans allure-results/
                robot -d %REPORT_DIR% --listener allure_robotframework:%ALLURE_RESULTS% tests
                '''
            }
        }
        stage('AI Analyze Results') {
    steps {
        bat '''
        python ai\\analyze_robot_output.py
        '''
    }
}
    }

    post {
        always {
           
            archiveArtifacts artifacts: 'reports/**, allure-results/**', fingerprint: true

            allure([
                includeProperties: false,
                jdk: '',
                results: [[path: 'allure-results']]
            ])
        }
    }
}