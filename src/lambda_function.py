import logging
logger = logging.getLogger()

def lambda_handler(event, context):
    logging.warning(
        "WARNING: Bucket access is public!",
        extra={
            "context" : context,
            "event" : event
        },
    )

    