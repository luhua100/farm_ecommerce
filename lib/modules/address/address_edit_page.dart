import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'address_edit_controller.dart';

class AddressEditPage extends GetView<AddressEditController> {
  const AddressEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(controller.title)),
      body: ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _InputRow(
                  title: '收货人',
                  controller: controller.nameController,
                  hintText: '请输入收货人姓名',
                ),
                _InputRow(
                  title: '手机号',
                  controller: controller.phoneController,
                  hintText: '请输入手机号',
                  keyboardType: TextInputType.number,
                ),
                _RegionRow(controller: controller),
                _InputRow(
                  title: '详细地址',
                  controller: controller.detailController,
                  hintText: '请输入详细地址',
                ),
                _DefaultRow(controller: controller),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
            child: SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: controller.save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD81E06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '保存地址',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.title,
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  final String title;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return _RowFrame(
      child: Row(
        children: [
          _RowTitle(title),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  const _RegionRow({required this.controller});

  final AddressEditController controller;

  @override
  Widget build(BuildContext context) {
    return _RowFrame(
      child: InkWell(
        onTap: () => _showRegionPicker(context),
        child: Row(
          children: [
            const _RowTitle('所在地区'),
            Expanded(
              child: Obx(
                () => Text(
                  controller.regionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: controller.province.value.isEmpty
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF111827),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Text(
              '›',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRegionPicker(BuildContext context) async {
    final selection = await showModalBottomSheet<RegionSelection>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const _RegionPickerSheet(),
    );
    if (selection != null) controller.setRegion(selection);
  }
}

class _DefaultRow extends StatelessWidget {
  const _DefaultRow({required this.controller});

  final AddressEditController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            const Text(
              '设为默认地址',
              style: TextStyle(color: Color(0xFF111827), fontSize: 14),
            ),
            const Spacer(),
            Obx(
              () => Switch(
                value: controller.isDefault.value,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => controller.isDefault.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowFrame extends StatelessWidget {
  const _RowFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
        ),
      ),
      child: child,
    );
  }
}

class _RowTitle extends StatelessWidget {
  const _RowTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      ),
    );
  }
}

class _RegionPickerSheet extends StatefulWidget {
  const _RegionPickerSheet();

  @override
  State<_RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<_RegionPickerSheet> {
  int cityIndex = 0;
  int districtIndex = 0;

  List<String> get cities => _hubeiRegions.keys.toList();
  List<String> get districts => _hubeiRegions[cities[cityIndex]]!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const Spacer(),
                  const Text(
                    '请选择省市区',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        RegionSelection(
                          province: '湖北省',
                          city: cities[cityIndex],
                          district: districts[districtIndex],
                        ),
                      );
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  const Expanded(child: _ProvinceColumn()),
                  Expanded(
                    child: _PickerColumn(
                      values: cities,
                      selectedIndex: cityIndex,
                      onSelected: (index) {
                        setState(() {
                          cityIndex = index;
                          districtIndex = 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _PickerColumn(
                      values: districts,
                      selectedIndex: districtIndex,
                      onSelected: (index) {
                        setState(() => districtIndex = index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProvinceColumn extends StatelessWidget {
  const _ProvinceColumn();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF5F7F4),
      child: Center(
        child: Text(
          '湖北省',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: values.length,
      itemBuilder: (_, index) {
        final selected = selectedIndex == index;
        return InkWell(
          onTap: () => onSelected(index),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            color: selected ? const Color(0xFFF3FAF6) : Colors.white,
            child: Text(
              values[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}

const _hubeiRegions = <String, List<String>>{
  '武汉市': [
    '江岸区',
    '江汉区',
    '硚口区',
    '汉阳区',
    '武昌区',
    '青山区',
    '洪山区',
    '东西湖区',
    '汉南区',
    '蔡甸区',
    '江夏区',
    '黄陂区',
    '新洲区',
  ],
  '荆州市': ['沙市区', '荆州区', '公安县', '监利市', '江陵县', '石首市', '洪湖市', '松滋市'],
  '宜昌市': [
    '西陵区',
    '伍家岗区',
    '点军区',
    '猇亭区',
    '夷陵区',
    '远安县',
    '兴山县',
    '秭归县',
    '长阳土家族自治县',
    '五峰土家族自治县',
    '宜都市',
    '当阳市',
    '枝江市',
  ],
  '襄阳市': ['襄城区', '樊城区', '襄州区', '南漳县', '谷城县', '保康县', '老河口市', '枣阳市', '宜城市'],
  '黄石市': ['黄石港区', '西塞山区', '下陆区', '铁山区', '阳新县', '大冶市'],
  '十堰市': ['茅箭区', '张湾区', '郧阳区', '郧西县', '竹山县', '竹溪县', '房县', '丹江口市'],
  '孝感市': ['孝南区', '孝昌县', '大悟县', '云梦县', '应城市', '安陆市', '汉川市'],
  '荆门市': ['东宝区', '掇刀区', '沙洋县', '钟祥市', '京山市'],
  '鄂州市': ['梁子湖区', '华容区', '鄂城区'],
  '黄冈市': ['黄州区', '团风县', '红安县', '罗田县', '英山县', '浠水县', '蕲春县', '黄梅县', '麻城市', '武穴市'],
  '咸宁市': ['咸安区', '嘉鱼县', '通城县', '崇阳县', '通山县', '赤壁市'],
  '随州市': ['曾都区', '随县', '广水市'],
  '恩施土家族苗族自治州': ['恩施市', '利川市', '建始县', '巴东县', '宣恩县', '咸丰县', '来凤县', '鹤峰县'],
  '省直辖县级行政区划': ['仙桃市', '潜江市', '天门市', '神农架林区'],
};
