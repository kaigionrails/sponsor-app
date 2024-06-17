// IF YOU EDIT ENVITORONMENT VARIABLES OR SECRETS, YOU SHOULD ALSO EDIT kaigionrails/terraform/aws/sponsor-app/*.tf FILES.
{
  parameterStoreArn(name):: std.format('arn:aws:ssm:us-west-2:861452569180:parameter/sponsor-app/%s', name),

  family: 'sponsor-app-worker',
  runtimePlatform: { operatingSystemFamily: 'LINUX' },
  taskRoleArn: 'arn:aws:iam::861452569180:role/SponsorApp',
  executionRoleArn: 'arn:aws:iam::861452569180:role/EcsExecSponsorApp',
  networkMode: 'awsvpc',
  containerDefinitions: [
    {
      name: 'app',
      image: '861452569180.dkr.ecr.us-west-2.amazonaws.com/sponsor-app:' + std.extVar('IMAGE_SHA'),
      cpu: 0,
      essential: true,
      command: ['bundle', 'exec', 'sidekiq', '--queue', 'default', '--queue', 'mailers'],
      environment: [
        {
          name: 'AWS_ACCESS_KEY_ID',
          value: 'sample',
        },
        {
          name: 'AWS_REGION',
          value: 'ap-northeast-1',
        },
        {
          name: 'AWS_SECRET_ACCESS_KEY',
          value: 'sample',
        },
        {
          name: 'DEFAULT_EMAIL_ADDRESS',
          value: 'sponsorships@kaigionrails.org',
        },
        {
          name: 'DEFAULT_EMAIL_HOST',
          value: 'sponsorships.kaigionrails.org',
        },
        {
          name: 'DEFAULT_URL_HOST',
          value: 'sponsorships.kaigionrails.org',
        },
        {
          name: 'LANG',
          value: 'en_US.UTF-8',
        },
        {
          name: 'MAILGUN_SMTP_SERVER',
          value: 'smtp.mailgun.org',
        },
        {
          name: 'ORG_NAME',
          value: 'Kaigi on Rails',
        },
        {
          name: 'RACK_ENV',
          value: 'production',
        },
        {
          name: 'RAILS_ENV',
          value: 'production',
        },
        {
          name: 'RAILS_LOG_TO_STDOUT',
          value: 'enabled',
        },
        {
          name: 'RAILS_SERVE_STATIC_FILES',
          value: 'enabled',
        },
        {
          name: 'SENTRY_ENV',
          value: 'production',
        },
      ],
      secrets: [
        {
          name: 'DATABASE_URL',
          valueFrom: $.parameterStoreArn('DATABASE_URL'),
        },
        {
          name: 'GITHUB_APP_ID',
          valueFrom: $.parameterStoreArn('GITHUB_APP_ID'),
        },
        {
          name: 'GITHUB_CLIENT_ID',
          valueFrom: $.parameterStoreArn('GITHUB_CLIENT_ID'),
        },
        {
          name: 'GITHUB_CLIENT_PRIVATE_KEY',
          valueFrom: $.parameterStoreArn('GITHUB_CLIENT_PRIVATE_KEY'),
        },
        {
          name: 'GITHUB_CLIENT_SECRET',
          valueFrom: $.parameterStoreArn('GITHUB_CLIENT_SECRET'),
        },
        {
          name: 'GITHUB_REPO',
          valueFrom: $.parameterStoreArn('GITHUB_REPO'),
        },
        {
          name: 'GOOGLE_CLOUD_CREDENTIALS',
          valueFrom: $.parameterStoreArn('GOOGLE_CLOUD_CREDENTIALS'),
        },
        {
          name: 'MAILGUN_API_KEY',
          valueFrom: $.parameterStoreArn('MAILGUN_API_KEY'),
        },
        {
          name: 'MAILGUN_SMTP_LOGIN',
          valueFrom: $.parameterStoreArn('MAILGUN_SMTP_LOGIN'),
        },
        {
          name: 'MAILGUN_SMTP_PASSWORD',
          valueFrom: $.parameterStoreArn('MAILGUN_SMTP_PASSWORD'),
        },
        {
          name: 'MAILGUN_SMTP_PORT',
          valueFrom: $.parameterStoreArn('MAILGUN_SMTP_PORT'),
        },
        {
          name: 'REDIS_TLS_URL',
          valueFrom: $.parameterStoreArn('REDIS_TLS_URL'),
        },
        {
          name: 'REDIS_URL',
          valueFrom: $.parameterStoreArn('REDIS_URL'),
        },
        {
          name: 'S3_FILES_BUCKET',
          valueFrom: $.parameterStoreArn('S3_FILES_BUCKET'),
        },
        {
          name: 'SECRET_KEY_BASE',
          valueFrom: $.parameterStoreArn('SECRET_KEY_BASE'),
        },
        {
          name: 'SLACK_WEBHOOK_URL',
          valueFrom: $.parameterStoreArn('SLACK_WEBHOOK_URL'),
        },
        {
          name: 'SENTRY_DSN',
          valueFrom: $.parameterStoreArn('SENTRY_DSN'),
        },
        {
          name: 'TITO_API_TOKEN',
          valueFrom: $.parameterStoreArn('TITO_API_TOKEN'),
        },
      ],
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/ecs/sponsor-app-worker',
          'awslogs-region': 'us-west-2',
          'awslogs-stream-prefix': 'ecs',
        },
      },
    },
  ],
  cpu: '256',
  memory: '512',
  tags: [
    {
      key: 'Project',
      value: 'kaigionrails',
    },
  ],
}
