import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);

  onModuleInit() {
    if (admin.apps.length === 0) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
          }),
        });
        this.logger.log('Firebase Admin SDK initialized successfully');
      } catch (error) {
        this.logger.error(`Failed to initialize Firebase Admin SDK: ${error.message}`);
      }
    }
  }

  async sendToDevice(token: string, title: string, body: string, data?: Record<string, string>): Promise<boolean> {
    try {
      const message: admin.messaging.Message = {
        token,
        notification: { title, body },
        data: data || {},
        android: {
          priority: 'high' as const,
          notification: {
            sound: 'default',
            channelId: 'fic_notifications',
          },
        },
      };

      const response = await admin.messaging().send(message);
      this.logger.log(`Notification sent successfully: ${response}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send notification to ${token}: ${error.message}`);
      // If token is invalid, return false so caller can remove it
      if (error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered') {
        return false;
      }
      return false;
    }
  }

  async sendToMultiple(tokens: string[], title: string, body: string, data?: Record<string, string>): Promise<string[]> {
    if (!tokens.length) return [];

    const invalidTokens: string[] = [];

    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: { title, body },
      data: data || {},
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
          channelId: 'fic_notifications',
        },
      },
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      this.logger.log(`Sent ${response.successCount}/${tokens.length} notifications`);

      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          this.logger.error(`Failed to send to token ${idx}: ${resp.error?.message}`);
          if (resp.error?.code === 'messaging/invalid-registration-token' ||
              resp.error?.code === 'messaging/registration-token-not-registered') {
            invalidTokens.push(tokens[idx]);
          }
        }
      });
    } catch (error) {
      this.logger.error(`Failed to send multicast notification: ${error.message}`);
    }

    return invalidTokens;
  }

  async sendToTopic(topic: string, title: string, body: string, data?: Record<string, string>): Promise<void> {
    try {
      await admin.messaging().send({
        topic,
        notification: { title, body },
        data: data || {},
        android: {
          priority: 'high' as const,
          notification: {
            sound: 'default',
            channelId: 'fic_notifications',
          },
        },
      });
      this.logger.log(`Notification sent to topic: ${topic}`);
    } catch (error) {
      this.logger.error(`Failed to send to topic ${topic}: ${error.message}`);
    }
  }
}
