//===--- MMIX.cpp - Implement MMIX target feature support -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements MMIX TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "MMIX.h"
#include "clang/Basic/MacroBuilder.h"
#include "llvm/ADT/StringSwitch.h"

using namespace clang;
using namespace clang::targets;


void MMIXTargetInfo::getTargetDefines(const LangOptions &Opts,
                                       MacroBuilder &Builder) const {
  Builder.defineMacro("__mmix__");
}

static constexpr llvm::StringLiteral ValidCPUNames[] = {"generic"};

bool MMIXTargetInfo::isValidCPUName(StringRef Name) const {
  return llvm::find(ValidCPUNames, Name) != std::end(ValidCPUNames);
}

void MMIXTargetInfo::fillValidCPUList(SmallVectorImpl<StringRef> &Values) const {
  Values.append(std::begin(ValidCPUNames), std::end(ValidCPUNames));
}

bool MMIXTargetInfo::setCPU(const std::string &Name) {
  StringRef CPUName(Name);
  return isValidCPUName(CPUName);
}

bool MMIXTargetInfo::hasFeature(StringRef Feature) const {
  return llvm::StringSwitch<bool>(Feature).Case("mmix", true).Default(false);
}

ArrayRef<const char *> MMIXTargetInfo::getGCCRegNames() const {
  static const char *const GCCRegNames[] = {
  "r0",    "r1",   "r2",   "r3",   "r4",   "r5",   "r6",   "r7",   "r8",   "r9",
  "r10",  "r11",  "r12",  "r13",  "r14",  "r15",  "r16",  "r17",  "r18",  "r19",
  "r20",  "r21",  "r22",  "r23",  "r24",  "r25",  "r26",  "r27",  "r28",  "r29",
  "r30",  "r31",  "r32",  "r33",  "r34",  "r35",  "r36",  "r37",  "r38",  "r39",
  "r40",  "r41",  "r42",  "r43",  "r44",  "r45",  "r46",  "r47",  "r48",  "r49",
  "r50",  "r51",  "r52",  "r53",  "r54",  "r55",  "r56",  "r57",  "r58",  "r59",
  "r60",  "r61",  "r62",  "r63",  "r64",  "r65",  "r66",  "r67",  "r68",  "r69",
  "r70",  "r71",  "r72",  "r73",  "r74",  "r75",  "r76",  "r77",  "r78",  "r79",
  "r80",  "r81",  "r82",  "r83",  "r84",  "r85",  "r86",  "r87",  "r88",  "r89",
  "r90",  "r91",  "r92",  "r93",  "r94",  "r95",  "r96",  "r97",  "r98",  "r99",

  "r100", "r101", "r102", "r103", "r104", "r105", "r106", "r107", "r108", "r109",
  "r110", "r111", "r112", "r113", "r114", "r115", "r116", "r117", "r118", "r119",
  "r120", "r121", "r122", "r123", "r124", "r125", "r126", "r127", "r128", "r129",
  "r130", "r131", "r132", "r133", "r134", "r135", "r136", "r137", "r138", "r139",
  "r140", "r141", "r142", "r143", "r144", "r145", "r146", "r147", "r148", "r149",
  "r150", "r151", "r152", "r153", "r154", "r155", "r156", "r157", "r158", "r159",
  "r160", "r161", "r162", "r163", "r164", "r165", "r166", "r167", "r168", "r169",
  "r170", "r171", "r172", "r173", "r174", "r175", "r176", "r177", "r178", "r179",
  "r180", "r181", "r182", "r183", "r184", "r185", "r186", "r187", "r188", "r189",
  "r190", "r191", "r192", "r193", "r194", "r195", "r196", "r197", "r198", "r199",

  "r200", "r201", "r202", "r203", "r204", "r205", "r206", "r207", "r208", "r209",
  "r210", "r211", "r212", "r213", "r214", "r215", "r216", "r217", "r218", "r219",
  "r220", "r221", "r222", "r223", "r224", "r225", "r226", "r227", "r228", "r229",
  "r230", "r231", "r232", "r233", "r234", "r235", "r236", "r237", "r238", "r239",
  "r240", "r241", "r242", "r243", "r244", "r245", "r246", "r247", "r248", "r249",
  "r250", "r251", "r252", "r253", "r254", "r255" };
  return llvm::makeArrayRef(GCCRegNames);
}
