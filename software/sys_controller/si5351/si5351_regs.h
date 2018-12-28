//
// Copyright (C) 2016-2018  Markus Hiienkari <mhiienka@niksula.hut.fi>
//
// This file is part of CPS2 Digital AV Interface project.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef SI5351_REGS_H_
#define SI5351_REGS_H_

#define SI5351_BASE 0x60

/* copied from export file */

#define SI5351C_REVB_REG_CONFIG_NUM_REGS				53

typedef struct
{
	unsigned int address; /* 16-bit register address */
	unsigned char value; /* 8-bit register data */

} si5351c_revb_register_t;

si5351c_revb_register_t const si5351c_revb_registers[SI5351C_REVB_REG_CONFIG_NUM_REGS] =
{
	{ 0x0002, 0x0B },
	{ 0x0003, 0x00 },
	{ 0x0007, 0x01 },
	{ 0x0009, 0xFF },
	{ 0x000A, 0xFF },
	{ 0x000C, 0x00 },
	{ 0x000D, 0x00 },
	{ 0x000F, 0x4C },
	{ 0x0010, 0x8C },
	{ 0x0011, 0x4C },
	{ 0x0012, 0x8C },
	{ 0x0013, 0x8C },
	{ 0x0014, 0x8C },
	{ 0x0015, 0x8C },
	{ 0x0016, 0x2F },
	{ 0x0017, 0x8C },
	{ 0x001A, 0x00 },
	{ 0x001B, 0x5B },
	{ 0x001C, 0x00 },
	{ 0x001D, 0x12 },
	{ 0x001E, 0x9A },
	{ 0x001F, 0x00 },
	{ 0x0020, 0x00 },
	{ 0x0021, 0x42 },
	{ 0x0022, 0x4F },
	{ 0x0023, 0x95 },
	{ 0x0024, 0x00 },
	{ 0x0025, 0x12 },
	{ 0x0026, 0x98 },
	{ 0x0027, 0x11 },
	{ 0x0028, 0x1B },
	{ 0x0029, 0x88 },
	{ 0x0032, 0x00 },
	{ 0x0033, 0x01 },
	{ 0x0034, 0x00 },
	{ 0x0035, 0x01 },
	{ 0x0036, 0x00 },
	{ 0x0037, 0x00 },
	{ 0x0038, 0x00 },
	{ 0x0039, 0x00 },
	{ 0x005A, 0x48 },
	{ 0x005B, 0x00 },
	{ 0x0095, 0x00 },
	{ 0x0096, 0x00 },
	{ 0x0097, 0x00 },
	{ 0x0098, 0x00 },
	{ 0x0099, 0x00 },
	{ 0x009A, 0x00 },
	{ 0x009B, 0x00 },
	{ 0x00A2, 0x00 },
	{ 0x00A3, 0x00 },
	{ 0x00A4, 0x00 },
	{ 0x00B7, 0x12 }
};


#endif /* SI5351_REGS_H_ */
