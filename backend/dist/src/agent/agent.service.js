"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AgentService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma.service");
let AgentService = class AgentService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(createAgentDto) {
        const { referredBy, ...rest } = createAgentDto;
        let referredById = null;
        if (referredBy) {
            const referrer = await this.prisma.agent.findUnique({
                where: { agentCode: referredBy }
            });
            if (referrer) {
                referredById = referrer.id;
            }
        }
        const createdAgent = await this.prisma.agent.create({
            data: {
                ...rest,
                ...(referredById ? { referredById } : {})
            },
        });
        return {
            ...createdAgent,
            referredBy: referredBy || null,
        };
    }
    async login(email, password) {
        const agent = await this.prisma.agent.findUnique({
            where: { email },
        });
        if (!agent) {
            throw new common_1.NotFoundException('No agent account found with this email');
        }
        if (!agent.password || agent.password !== password) {
            throw new common_1.UnauthorizedException('Invalid password');
        }
        return agent;
    }
    async findAll() {
        return this.prisma.agent.findMany();
    }
    async findOne(id) {
        return this.prisma.agent.findUnique({
            where: { id },
        });
    }
    async findByPhone(phoneNumber) {
        return this.prisma.agent.findUnique({
            where: { phoneNumber },
        });
    }
    async update(id, updateAgentDto) {
        return this.prisma.agent.update({
            where: { id },
            data: updateAgentDto,
        });
    }
    async remove(id) {
        return this.prisma.agent.delete({
            where: { id },
        });
    }
};
exports.AgentService = AgentService;
exports.AgentService = AgentService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AgentService);
//# sourceMappingURL=agent.service.js.map