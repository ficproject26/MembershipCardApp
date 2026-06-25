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
exports.StaffService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma.service");
let StaffService = class StaffService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(data) {
        return this.prisma.staff.create({
            data,
        });
    }
    async findAll() {
        return this.prisma.staff.findMany({
            orderBy: { dateJoined: 'desc' },
        });
    }
    async findOne(id) {
        const staff = await this.prisma.staff.findUnique({
            where: { id },
        });
        if (!staff)
            throw new common_1.NotFoundException('Staff not found');
        return staff;
    }
    async login(email, password) {
        const staff = await this.prisma.staff.findUnique({
            where: { email },
        });
        if (!staff)
            throw new common_1.NotFoundException('No staff account found with this email');
        if (!staff.password || staff.password !== password) {
            throw new common_1.UnauthorizedException('Invalid password');
        }
        const { password: _, ...staffWithoutPassword } = staff;
        return staffWithoutPassword;
    }
    async update(id, data) {
        return this.prisma.staff.update({
            where: { id },
            data,
        });
    }
    async remove(id) {
        return this.prisma.staff.delete({
            where: { id },
        });
    }
};
exports.StaffService = StaffService;
exports.StaffService = StaffService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StaffService);
//# sourceMappingURL=staff.service.js.map