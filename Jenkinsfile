pipeline {
    agent any

    tools {
        jdk 'jdk'
        nodejs 'node17'
    }

    environment {
        SCANNER_HOME = tool 'Sonar-Scanner'
        Version = "${BUILD_NUMBER}"
    }

    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', credentialsId: 'Git-Creds', url: 'https://github.com/Murali-Kaspa/Starbucks-Project-DevSecops.git'
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('Sonar-Server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=starbucks-project-test \
                        -Dsonar.projectKey=starbucks-project-test
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'npm install'
                }
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'trivy fs . > trivyfs.txt'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        withDockerRegistry([credentialsId: 'Docker-Creds', toolName: 'docker']) {
                            sh '''
                                docker build -t starbucks .
                                docker tag starbucks muralikaspa1998/starbucks:${Version}
                                docker push muralikaspa1998/starbucks:${Version}
                            '''
                        }
                    }
                }
            }
        }

        stage('TRIVY IMAGE SCAN') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "trivy image muralikaspa1998/starbucks:${Version} > trivyimage.txt"
                }
            }
        }

        stage('App Deploy to Docker container') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        docker run -d --name starbucks-${BUILD_NUMBER} -p 3000:3000 muralikaspa1998/starbucks:${Version}
                    """
                }
            }
        }

        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = "Starbucks-Project-Devsecops"
                GIT_USER_NAME = "Murali-Kaspa"
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    withCredentials([gitUsernamePassword(credentialsId: 'Git-Creds', gitToolName: 'Default')]) {
                        echo 'Update Deployment File'
                        sh '''
                            git config user.email "murali.kaspa26@gmail.com"
                            git config user.name "Murali-Kaspa"
                            rm -rf *.rpm.*
                            sed -i "s#muralikaspa1998/starbucks:.*#muralikaspa1998/starbucks:${BUILD_NUMBER}#g" Kubernetes/deployment.yaml
                            git add .
                            git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                            git push -u origin main
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Build succeeded!</p>
                    <p><b>Project:</b> ${env.JOB_NAME}</p>
                    <p><b>Build #:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "murali.kaspa26@gmail.com",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Build failed!</p>
                    <p>Check console output: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "murali.kaspa26@gmail.com",
                mimeType: 'text/html'
            )
        }
    }
}
