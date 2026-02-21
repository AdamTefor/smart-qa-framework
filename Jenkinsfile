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
        script {
            def rc = bat(returnStatus: true, script: """
                if not exist ${REPORT_DIR} mkdir ${REPORT_DIR}
                if not exist ${ALLURE_RESULTS} mkdir ${ALLURE_RESULTS}

                robot -d ${REPORT_DIR} --listener allure_robotframework:${ALLURE_RESULTS} tests
            """)

            // rc = 0 si tout PASS, rc = 1 si au moins un FAIL
            if (rc == 1) {
                currentBuild.result = 'UNSTABLE'
                echo "Robot tests have failures (exit code 1) -> marking build UNSTABLE."
            } else if (rc != 0) {
                error "Robot execution failed with exit code: ${rc}"
            }
        }
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