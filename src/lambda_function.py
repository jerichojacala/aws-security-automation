import logging
import json
logger = logging.getLogger()

def lambda_handler(event, context):
    log_event(event)
    return {
            'statusCode': 200,
            'body': json.dumps('Compliance status processed successfully')
    }

def log_event(event):

    detail = event.get("detail", {})
    new_eval = detail.get("newEvaluationResult", {})

    compliance_type = new_eval.get("complianceType")
    config_rule_name = detail.get("configRuleName")
    resource_id = detail.get("resourceId")

    status = False

    if compliance_type.lower() == "non_compliant":
        logger.warning(
                f"WARNING: Bucket access is public! Event: {event}",
                extra={
                    "event" : event
                },
        )
    elif compliance_type.lower() == "compliant":
        logger.info(
            f"Resource {resource_id} is compliant with rule {config_rule_name}. Event: {event}",
            extra={
                "event" : event
            }
        )
        status = True
    else:
        logger.warning(
            f"WARNING: Bucket access is indeterminate! Event: {event}",
                extra={
                    "event" : event
                },
        )

    return status
    