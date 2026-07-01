import { StatusService } from './status.service';
export declare class StatusController {
    private readonly statusService;
    constructor(statusService: StatusService);
    getActiveStatuses(): Promise<any>;
    createStatus(body: {
        userId: string;
        userName: string;
        content: string;
    }): Promise<any>;
    createMediaStatus(file: Express.Multer.File, body: {
        userId: string;
        userName: string;
        content?: string;
        type: string;
    }): Promise<any>;
    deleteStatus(id: string): Promise<any>;
}
