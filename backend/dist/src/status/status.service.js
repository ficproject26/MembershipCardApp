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
exports.StatusService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma.service");
let StatusService = class StatusService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createStatus(userId, userName, content, type = 'TEXT', mediaUrl) {
        return this.prisma.statusUpdate.create({
            data: {
                userId,
                userName,
                content,
                type,
                mediaUrl,
            },
        });
    }
    async getActiveStatuses() {
        const yesterday = new Date();
        yesterday.setHours(yesterday.getHours() - 24);
        return this.prisma.statusUpdate.findMany({
            where: {
                createdAt: {
                    gte: yesterday,
                },
            },
            orderBy: {
                createdAt: 'asc',
            },
        });
    }
    async deleteStatus(id) {
        return this.prisma.statusUpdate.delete({
            where: { id },
        });
    }
};
exports.StatusService = StatusService;
exports.StatusService = StatusService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StatusService);
//# sourceMappingURL=status.service.js.map