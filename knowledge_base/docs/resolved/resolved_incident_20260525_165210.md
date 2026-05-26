# Resolved Incident — payment-db pool_exhaustion

**Date:** 2026-05-25 16:52 UTC
**Service:** payment-db
**Error Type:** pool_exhaustion
**Severity:** high
**Diagnosis Confidence:** 92%

## Original Report
payment-db is throwing too many clients error after today's deployment

## Root Cause
The root cause of the pool exhaustion in payment-db was the deployment of payment-service v2.4.0, which doubled the application instances from 4 to 8 without adjusting the PgBouncer pool size, leading to too many clients error.

## Resolution Steps (Engineer Approved)
- Primary Fix:
- Check the current PgBouncer pool size configuration to confirm it is set too low for the increased application instances.
- Temporarily increase the PgBouncer pool size to accommodate the new number of application instances (8) while monitoring the database performance.
- Monitor the database connection metrics to ensure that the pool exhaustion error is resolved after the adjustment.
- If the issue persists, consider rolling back the payment-service deployment to v2.3.0 as a last resort.
- Alternative Approaches:
- Option A: Scale down the number of application instances from 8 back to 4 to match the existing PgBouncer pool size until a more permanent solution is implemented.
- Option B: Implement connection pooling at the application level to reduce the number of connections made to the database, thereby alleviating the pool exhaustion issue.
- Option C: Review and optimize the database queries used by payment-service v2.4.0 to ensure they are not causing excessive connection usage.

## Notes
This incident was diagnosed by the AI system and approved by an engineer.
Added to the knowledge base automatically after approval.
