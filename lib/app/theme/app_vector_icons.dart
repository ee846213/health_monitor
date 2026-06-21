/// `health-monitor-app-design.pen` 使用的同源 Material Symbols Rounded 资源。
///
/// 文件来自 Google Material Design Icons 官方仓库。页面只能通过本类引用，
/// 避免在业务组件内拼接路径或退回到轮廓不同的 `Icons.*` 近似图标。
class AppVectorIcons {
  const AppVectorIcons._();

  static const String _root = 'assets/icons/common/material_symbols_rounded';

  static String path(String icon, {int weight = 400}) {
    assert(weight == 400 || weight == 500);
    return '$_root/${icon}_wght$weight.svg';
  }

  static const String profilePlant =
      'assets/illustrations/common/profile_plant.svg';
}
