# Resolved Incident — payment-db pool_exhaustion

**Date:** 2026-05-25 16:48 UTC
**Service:** payment-db
**Error Type:** pool_exhaustion
**Severity:** high
**Diagnosis Confidence:** 92%

## Original Report
payment-db is throwing too many clients error after deployment. Severity is high.

## Root Cause
The root cause of the pool exhaustion in payment-db was the deployment of payment-service v2.4.0, which doubled the application instances from 4 to 8 without adjusting the PgBouncer pool size, leading to too many clients error.

## Resolution Steps (Engineer Approved)
- Primary Fix:
- Check the current PgBouncer pool size configuration to confirm it is set too low for the increased application instances.
- Increase the PgBouncer pool size to accommodate the new number of application instances (e.g., set it to 16 if using a 2:1 ratio).
- Monitor the connection metrics in PgBouncer to ensure that the pool is no longer exhausted after the adjustment.
- If the issue persists, consider temporarily reducing the number of application instances back to 4 until the pool size can be optimized.
- Alternative Approaches:
- Option A: Review the database connection settings in the payment-service v2.4.0 deployment and adjust them to use a lower number of connections per instance.
- Option B: Scale down the number of application instances from 8 back to 4 to alleviate the immediate pressure on the database connections while you adjust the PgBouncer settings.
- Option C: Implement connection pooling at the application level to further reduce the number of concurrent connections to the database.

## Notes
This incident was diagnosed by the AI system and approved by an engineer.
Added to the knowledge base automatically after approval.
