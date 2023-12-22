#!/usr/bin/env python3

import aws_cdk as cdk

from event_processing_with_sqs.event_processing_with_sqs_stack import EventProcessingWithSqsStack

app = cdk.App()
EventProcessingWithSqsStack(app, "event-processing-with-sqs")

app.synth()
