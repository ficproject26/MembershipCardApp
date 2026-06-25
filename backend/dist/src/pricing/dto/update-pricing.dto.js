"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdatePricingDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_pricing_dto_1 = require("./create-pricing.dto");
class UpdatePricingDto extends (0, mapped_types_1.PartialType)(create_pricing_dto_1.CreatePricingDto) {
}
exports.UpdatePricingDto = UpdatePricingDto;
//# sourceMappingURL=update-pricing.dto.js.map