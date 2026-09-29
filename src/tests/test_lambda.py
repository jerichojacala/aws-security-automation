from unittest.mock import Mock

from lambda_function import lambda_handler

def sample_event(compliance="NON_COMPLIANT"):
    return {
        "version": "0",
        "id": "24ed1442-da3f-bce5-1123-1be1e3c3bd80",
        "detail-type": "Config Rules Compliance Change",
        "source": "aws.config",
        "account": "389360277303",
        "time": "2026-09-27T15:45:44Z",
        "region": "us-east-1",
        "resources": [],
        "detail": {
            "resourceType": "AWS::S3::Bucket",
            "resourceId": "jjacala-config-history-a54014e8309b653a6c9762d813",
            "awsRegion": "us-east-1",
            "awsAccountId": "389302730725",
            "configRuleName": "s3-public-read-prohibited",
            "configRuleARN": "arn:aws:config:us-east-1:389360277303:config-rule/config-rule-dtv0id",
            "messageType": "ComplianceChangeNotification",
            "recordVersion": "1.0",
            "notificationCreationTime": "2026-09-27T15:45:44.223Z",
            "newEvaluationResult": {
                "complianceType": compliance,
                "resultRecordedTime": "2026-09-27T15:45:43.234Z",
                "configRuleInvokedTime": "2026-09-27T15:45:42.905Z",
                "evaluationResultIdentifier": {
                    "orderingTimestamp": "2026-09-27T15:45:10.170Z",
                    "evaluationResultQualifier": {
                    "configRuleName": "s3-public-read-prohibited",
                    "resourceType": "AWS::S3::Bucket",
                    "resourceId": "jjacala-config-history-a54014e8309b653a6c9762d813",
                    "evaluationMode": "DETECTIVE"
                    }
                }
            },
            "oldEvaluationResult": {
                "complianceType": "COMPLIANT",
                "resultRecordedTime": "2026-09-27T15:44:14.384Z",
                "configRuleInvokedTime": "2026-09-27T15:44:13.711Z",
                "evaluationResultIdentifier": {
                    "orderingTimestamp": "2026-09-27T15:43:39.461Z",
                    "evaluationResultQualifier": {
                        "configRuleName": "s3-public-read-prohibited",
                        "resourceType": "AWS::S3::Bucket",
                        "resourceId": "jjacala-config-history-a54014e8309b653a6c9762d813",
                        "evaluationMode": "DETECTIVE"
                    }   
                }
            }
        }
    }