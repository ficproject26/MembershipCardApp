import { StaffService } from './staff.service';
import { Prisma } from '@prisma/client';
export declare class StaffController {
    private readonly staffService;
    constructor(staffService: StaffService);
    create(createStaffDto: Prisma.StaffCreateInput): Promise<any>;
    login(body: {
        email: string;
        password: string;
    }): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: string): Promise<any>;
    update(id: string, updateStaffDto: Prisma.StaffUpdateInput): Promise<any>;
    remove(id: string): Promise<any>;
}
