import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorState extends StatelessWidget {
  final Function()? onTap;
  const ErrorState({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('加载失败'),
          OutlinedButton(
            onPressed: onTap,
            child: const Text('重新加载'),
          )
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final Function()? onTap;

  const EmptyState({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lightbulb_outline),
          const Text('暂无数据'),
          OutlinedButton(onPressed: onTap, child: const Text('刷新')),
        ],
      ),
    );
  }
}
