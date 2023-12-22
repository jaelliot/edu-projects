from constructs import Construct
from aws_cdk import (
    Duration,
    Stack,
    aws_sqs as sqs,
    aws_lambda as lambda_,
    aws_lambda_event_sources as lambda_event_sources
)

class EventProcessingWithSqsStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create our Queue
        queue = sqs.Queue(
            self, "EventProcessingWithSqsQueue",
            visibility_timeout=Duration.seconds(300),
        )

        # Create our Lambda Function
        sqs_lambda = lambda_.Function(
            self, "SQSLambda",
            handler='lambda_handler.handler',
            runtime=lambda_.Runtime.PYTHON_3_10,  # Adjust the runtime version as needed
            code=lambda_.Code.from_asset('lambda')  # Ensure 'lambda' directory exists with your Lambda code
        )

        # Create our event source
        sqs_event_source = lambda_event_sources.SqsEventSource(queue)

        # Add SQS event source to Lambda
        sqs_lambda.add_event_source(sqs_event_source)
