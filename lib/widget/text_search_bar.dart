import 'package:flutter/material.dart';

class TextSearchBar extends StatelessWidget {
  final String title;

  final TextEditingController controller;
  final Function(String text)? submit;
  final Function()? clear;
  TextSearchBar({required this.title, required this.controller, this.clear, this.submit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clearColor =  theme.primaryColor == Colors.black ? Colors.black : Colors.white;
    return Container(
      padding: EdgeInsets.only(left: 15),
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Ink(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.search_rounded, color: Color(0xff999999), size: 24),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: controller,
                      // autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: submit,
                      decoration: InputDecoration(
                        hintText: title,
                        hintStyle: const TextStyle(
                          color: Color(0xff999999),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true, //是文本垂直居中
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: InkWell(
                      onTap: clear,
                      borderRadius: BorderRadius.circular(18),
                      child: Icon(Icons.close_rounded, size: 20, color: Color(0xff999999)),
                    ),
                  )
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            child:  Text(
              '取消',
              style: TextStyle(
                color: clearColor,
                fontSize: 17,
                fontWeight: FontWeight.normal
              ),
            ),
          ),
        ],
      ),
    );
  }
}
