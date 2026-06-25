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
exports.LeadService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma.service");
let LeadService = class LeadService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(createLeadDto) {
        return this.prisma.lead.create({
            data: createLeadDto,
            include: { agent: true },
        });
    }
    async findAll() {
        return this.prisma.lead.findMany({
            include: { agent: true },
        });
    }
    async findOne(id) {
        return this.prisma.lead.findUnique({
            where: { id },
            include: { agent: true },
        });
    }
    async findByAgent(agentId) {
        return this.prisma.lead.findMany({
            where: { agentId },
            include: { agent: true },
        });
    }
    async update(id, updateLeadDto) {
        return this.prisma.lead.update({
            where: { id },
            data: updateLeadDto,
        });
    }
    async remove(id) {
        return this.prisma.lead.delete({
            where: { id },
        });
    }
};
exports.LeadService = LeadService;
exports.LeadService = LeadService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], LeadService);
//# sourceMappingURL=lead.service.js.map