import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

/**
 * Global throttle guard — rate limiting for all API endpoints.
 * Default: 100 requests per 60 seconds per IP.
 * Auth endpoints override with stricter limits via @Throttle() decorator.
 */
@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
  protected async getTracker(req: Record<string, any>): Promise<string> {
    // Use IP address as the tracker key
    return req.ip || req.connection?.remoteAddress || 'unknown';
  }
}
