import { AgentService } from './agent.service';
import { CreateAgentDto } from './dto/create-agent.dto';
import { UpdateAgentDto } from './dto/update-agent.dto';
export declare class AgentController {
    private readonly agentService;
    constructor(agentService: AgentService);
    create(createAgentDto: CreateAgentDto): Promise<any>;
    login(body: {
        email: string;
        password?: string;
    }): Promise<any>;
    findAll(): Promise<any>;
    findOne(id: string): Promise<any>;
    update(id: string, updateAgentDto: UpdateAgentDto): Promise<any>;
    remove(id: string): Promise<any>;
}
