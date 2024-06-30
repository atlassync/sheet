import 'package:flutter/material.dart';
import 'dart:math' as math;

class SingleExtentSnappingScrollPhysics extends ScrollPhysics {
  const SingleExtentSnappingScrollPhysics(
    this.extent, {
    super.parent,
  });

  final double extent;

  @override
  SingleExtentSnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SingleExtentSnappingScrollPhysics(extent,
        parent: buildParent(ancestor));
  }

  double _getItemExtent(ScrollMetrics position) {
    return extent;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      final double target = _getTargetPixels(position, tolerance, velocity);
      if ((target - position.pixels).abs() < tolerance.distance) {
        return null;
      }
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return super.createBallisticSimulation(position, velocity);
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / _getItemExtent(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return math.min(page.roundToDouble() * _getItemExtent(position),
        position.maxScrollExtent);
  }
}

class MultiExtentSnappingScrollPhysics extends ScrollPhysics {
  final List<double> extents;

  const MultiExtentSnappingScrollPhysics(this.extents, {super.parent});

  @override
  MultiExtentSnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MultiExtentSnappingScrollPhysics(extents,
        parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      final double target = _getTargetPixels(position, tolerance, velocity);
      if ((target - position.pixels).abs() < tolerance.distance) {
        return null;
      }
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double currentOffset = position.pixels;
    double closestOffset = 0.0;
    double minDifference = double.infinity;

    double cumulativeOffset = 0.0;
    for (double extent in extents) {
      double difference = (currentOffset - cumulativeOffset).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestOffset = cumulativeOffset;
      }
      cumulativeOffset += extent;
    }

    if (velocity < -tolerance.velocity) {
      closestOffset = closestOffset - extents[0] / 2;
    } else if (velocity > tolerance.velocity) {
      closestOffset = closestOffset + extents[0] / 2;
    }

    return math.min(closestOffset, position.maxScrollExtent);
  }
}
