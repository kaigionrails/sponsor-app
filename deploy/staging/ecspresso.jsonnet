{
  region: 'us-west-2',
  cluster: 'kor-usw2-fargate',
  service: 'sponsor-app-staging-worker',
  service_definition: 'service_definition.jsonnet',
  task_definition: 'task_definition.jsonnet',
  timeout: '5m',
}
