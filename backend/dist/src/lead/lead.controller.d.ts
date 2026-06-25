import { LeadService } from './lead.service';
import { CreateLeadDto } from './dto/create-lead.dto';
import { UpdateLeadDto } from './dto/update-lead.dto';
export declare class LeadController {
    private readonly leadService;
    constructor(leadService: LeadService);
    create(createLeadDto: CreateLeadDto): Promise<any>;
    findAll(): Promise<any>;
    findByAgent(agentId: string): Promise<any>;
    findOne(id: string): Promise<any>;
    update(id: string, updateLeadDto: UpdateLeadDto): Promise<any>;
    remove(id: string): Promise<any>;
}
