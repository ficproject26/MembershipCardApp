"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const agent_module_1 = require("./agent/agent.module");
const lead_module_1 = require("./lead/lead.module");
const pricing_module_1 = require("./pricing/pricing.module");
const prisma_module_1 = require("./prisma.module");
const staff_module_1 = require("./staff/staff.module");
const auth_module_1 = require("./auth/auth.module");
const integrations_module_1 = require("./integrations/integrations.module");
const queue_module_1 = require("./queue/queue.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [prisma_module_1.PrismaModule, agent_module_1.AgentModule, lead_module_1.LeadModule, pricing_module_1.PricingModule, staff_module_1.StaffModule, auth_module_1.AuthModule, integrations_module_1.IntegrationsModule, queue_module_1.QueueModule],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map