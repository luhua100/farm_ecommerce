import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/empty_state.dart';
import 'member_controller.dart';

class MemberPage extends GetView<MemberController> {
  const MemberPage({super.key});

  static const _cardGreen = Color(0xFF173D2B);
  static const _gold = Color(0xFFF6D999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(title: const Text('会员中心')),
      body: Obx(() {
        final member = controller.member.value ?? MemberInfoModel();
        if (controller.loading.value && controller.member.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _MemberCard(member: member),
              const SizedBox(height: 10),
              _BenefitsSection(member: member),
              const SizedBox(height: 10),
              _LevelsSection(member: member),
              const SizedBox(height: 10),
              _PointsSection(points: controller.points),
            ],
          ),
        );
      }),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final MemberInfoModel member;

  @override
  Widget build(BuildContext context) {
    final progress = (member.progressPercent / 100).clamp(0.0, 1.0);
    final next = member.nextLevel;
    final progressText = next == null
        ? '🎉 已达最高等级'
        : '距${next.name}还需${(next.minPoints - member.points).clamp(0, 999999)}积分';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MemberPage._cardGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(member.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  member.levelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${member.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    '当前积分',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            progressText,
            style: TextStyle(
              color: next == null
                  ? MemberPage._gold
                  : Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(MemberPage._gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection({required this.member});

  final MemberInfoModel member;

  static const _benefits = [
    (0, '🎁', '新人礼包', '注册即送100积分'),
    (1, '💰', '专属折扣', '全场商品享会员折扣'),
    (2, '🚚', '免运费', '订单满99免运费'),
    (3, '⭐', '专属客服', '1对1专属服务'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '会员权益',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.45,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        children: _benefits.map((item) {
          final active = member.level >= item.$1;
          return Opacity(
            opacity: active ? 1 : 0.72,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFEDF6EF)
                    : const Color(0xFFF5F7F4).withValues(alpha: 0.56),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Text(item.$2, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.$3,
                          style: const TextStyle(
                            color: Color(0xFF18211B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LevelsSection extends StatelessWidget {
  const _LevelsSection({required this.member});

  final MemberInfoModel member;

  @override
  Widget build(BuildContext context) {
    final levels = member.levels.isNotEmpty ? member.levels : _defaultLevels;
    return _SectionCard(
      title: '等级说明',
      child: Column(
        children: [
          _levelRow('等级', '所需积分', '折扣', header: true),
          ...levels.map(
            (item) => _levelRow(
              item.displayName,
              '${item.minPoints}',
              item.displayDiscount,
              active: item.level == member.level,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelRow(
    String name,
    String points,
    String discount, {
    bool header = false,
    bool active = false,
  }) {
    final color = header
        ? AppColors.textSecondary
        : active
        ? AppColors.primary
        : AppColors.textPrimary;
    final weight = header || active ? FontWeight.w700 : FontWeight.w400;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4EADF), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: TextStyle(color: color, fontWeight: weight),
            ),
          ),
          Expanded(
            child: Text(
              points,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: weight),
            ),
          ),
          Expanded(
            child: Text(
              discount,
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: weight),
            ),
          ),
        ],
      ),
    );
  }

  static final _defaultLevels = [
    MemberLevelModel(
      level: 0,
      name: '普通会员',
      minPoints: 0,
      discount: '无',
      icon: '👤',
    ),
    MemberLevelModel(
      level: 1,
      name: '银卡会员',
      minPoints: 500,
      discount: '9.8折',
      icon: '🥈',
    ),
    MemberLevelModel(
      level: 2,
      name: '金卡会员',
      minPoints: 2000,
      discount: '9.5折',
      icon: '🥇',
    ),
    MemberLevelModel(
      level: 3,
      name: '钻石会员',
      minPoints: 5000,
      discount: '9折',
      icon: '💎',
    ),
  ];
}

class _PointsSection extends StatelessWidget {
  const _PointsSection({required this.points});

  final List<PointsHistoryModel> points;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '积分记录',
      child: points.isEmpty
          ? const EmptyState(title: '暂无积分记录')
          : Column(
              children: points
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.displayTime,
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.points >= 0
                                ? '+${item.points}'
                                : '${item.points}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
