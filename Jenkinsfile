/*
 *
 */

pipeline {
    agent any
    environment {
        SPEC_OPTS = '--format=documentation --order=random'
    }

    stages {
        stage('Ruby 2.1') {
            agent { docker 'ruby:2.1-alpine' }
            steps {
                parallel(
                    '3.8.0' : {
                        sh 'PUPPET_VERSION="~> 3.8.0" bundle install --without development'
                        sh 'bundle exec rake'
                    },
                    '4.9.0' : {
                        sh 'PUPPET_VERSION="~> 4.9.0" bundle install --without development'
                        sh 'bundle exec rake'
                    },
                )
            }
        }
        stage('Ruby 2.2') {
            agent { docker 'ruby:2.2-alpine' }
            steps {
                echo 'Hello World'
            }
        }

    }
}
